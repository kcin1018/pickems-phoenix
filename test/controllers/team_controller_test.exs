defmodule Pickems.TeamControllerTest do
  use Pickems.ConnCase

  alias Pickems.Team
  @valid_attrs %{is_paid: true, name: "Team name"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    # Create a user (bypasses validation
    user = Repo.insert! %Pickems.User{}
    # Encode a token for the user
    { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)

    conn = conn
    |> put_req_header("content-type", "application/vnd.api+json") # JSON-API content-type
    |> put_req_header("authorization", "Bearer #{jwt}") # Add token to auth header

    {:ok, %{conn: conn, user: user}} # Pass user object to each test
  end

  defp create_test_teams(user) do
    # Create three teams owned by the logged in user
    Enum.each ["team 1", "team 2", "team 3"], fn name ->
      Repo.insert! %Pickems.Team{owner_id: user.id, name: name, is_paid: false}
    end

    # Create two teams owned by another user
    other_user = Repo.insert! %Pickems.User{}
    Enum.each ["team 4", "team 5"], fn name ->
      Repo.insert! %Pickems.Team{owner_id: other_user.id, name: name, is_paid: false}
    end
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    # Build test teams
    create_test_teams user
    # List of all teams
    conn = get conn, team_path(conn, :index)
    assert Enum.count(json_response(conn, 200)["data"]) == 5
  end

  test "lists owned entries on index (owner_id = user id)", %{conn: conn, user: user} do
    # Build test teams
    create_test_teams user
    # List of teams owned by user
    conn = get conn, team_path(conn, :index, user_id: user.id)
    assert Enum.count(json_response(conn, 200)["data"]) == 3
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    team = Repo.insert! %Team{owner_id: user.id}
    conn = get conn, team_path(conn, :show, team)
    assert json_response(conn, 200)["data"] == %{
      "id" => to_string(team.id),
      "type" => "team",
      "attributes" => %{
        "name" => team.name
        "is-paid" => team.is_paid
      },
      "relationships" => %{
        "owner" => %{
          "data" => %{
            "id" => user.id,
            "type" => "users"
          }
        }
      }
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn, user: _user} do
    assert_error_sent 404, fn ->
      get conn, team_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, user: _user} do
    conn = post conn, team_path(conn, :create), data: %{type: "teams", attributes: @valid_attrs, relationships: %{}}
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: _user} do
    conn = post conn, team_path(conn, :create), data: %{type: "teams", attributes: @invalid_attrs, relationships: %{}}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    team = Repo.insert! %Team{owner_id: user.id, name: "A team"}
    conn = put conn, team_path(conn, :update, team), data: %{id: team.id, type: "teams", attributes: @valid_attrs}
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    team = Repo.insert! %Team{owner_id: user.id}
    conn = put conn, team_path(conn, :update, team), data: %{id: team.id, type: "teams", attributes: @invalid_attrs}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    team = Repo.insert! %Team{owner_id: user.id }
    conn = delete conn, team_path(conn, :delete, team)
    assert response(conn, 204)
    refute Repo.get(Team, team.id)
  end
end

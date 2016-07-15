defmodule Pickems.UserControllerTest do
  use Pickems.ConnCase

  alias Pickems.User

  @valid_attrs %{
    email: "testuser@example.com",
    name: "Test User",
    password: "fqhi12hrrfasf",
    "password-confirmation": "fqhi12hrrfasf",
    admin: false
  }

  @valid_token %{
    grant_type: "password",
    username: "testuser@example.com",
    password: "fqhi12hrrfasf"
  }

  @invalid_token %{
    grant_type: "other_auth",
    username: "testuser@example.com",
    password: "fqhi12hrrfasf"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "current user route is unauthorized when a user is not authenticated", %{conn: conn} do
    conn = get conn, user_path(conn, :current)
    assert json_response(conn, 401)["errors"]
  end

  test "displays the current user logged in when logged in", %{conn: conn} do
    # Create a user (bypasses validation
    user = Repo.insert! %User{}
    # Encode a token for the user
    { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)

    conn = conn
    |> put_req_header("content-type", "application/vnd.api+json") # JSON-API content-type
    |> put_req_header("authorization", "Bearer #{jwt}") # Add token to auth header

    conn = get conn, user_path(conn, :current)
    assert json_response(conn, 200)["data"]["id"]
    assert json_response(conn, 200)["data"]["type"] == "user"
  end

end

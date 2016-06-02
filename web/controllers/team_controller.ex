defmodule Pickems.TeamController do
  use Pickems.Web, :controller
  import Ecto.Query

  alias Pickems.Team

  plug Guardian.Plug.EnsureAuthenticated, handler: Pickems.AuthErrorHandler

  # plug :scrub_params, "team" when action in [:create, :update]
  import Ecto.Query, only: [where: 2]

  def index(conn, %{"user_id" => user_id}) do
    teams = Team
    |> where(owner_id: ^user_id)
    |> Repo.all

    render(conn, "index.json", data: teams)
  end

  # Full list of teams
  def index(conn, _params) do
    teams = Repo.all(Team)
    render(conn, "index.json", data: teams)
  end

  def create(conn, %{"data" => %{"type" => "teams", "attributes" => team_attributes, "relationships" => _}}) do
    # Get the current user
    current_user = Guardian.Plug.current_resource(conn)
    # Build the current user's ID into the changeset
    changeset = Team.changeset(%Team{owner_id: current_user.id}, team_attributes)

    case Repo.insert(changeset) do
      {:ok, team} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", team_path(conn, :show, team))
        |> render("show.json", data: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Pickems.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)
    render(conn, "show.json", data: team)
  end

  def update(conn, %{"id" => id, "data" => %{"id" => _, "type" => "teams", "attributes" => team_attributes}}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Team
    |> where(owner_id: ^current_user.id, id: ^id)
    |> Repo.one!

    changeset = Team.changeset(team, team_attributes)

    case Repo.update(changeset) do
      {:ok, team} ->
        render(conn, "show.json", data: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Pickems.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    team = Team
    |> where(owner_id: ^current_user.id, id: ^id)
    |> Repo.one!

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(team)

    send_resp(conn, :no_content, "")
  end
end

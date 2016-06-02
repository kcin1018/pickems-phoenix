defmodule Pickems.TeamView do
  use Pickems.Web, :view

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, Pickems.TeamView, "team.json")}
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, Pickems.TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    %{id: team.id,
      name: team.name,
      owner_id: team.owner_id,
      is_paid: team.is_paid}
  end
end

defmodule Pickems.TeamView do
  use Pickems.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :is_paid]
  has_one :owner, link: :user_link

  def user_link(team, conn) do
    user_url(conn, :show, team.owner_id)
  end
end

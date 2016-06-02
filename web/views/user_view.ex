defmodule Pickems.UserView do
  use Pickems.Web, :view
  use JaSerializer.PhoenixView

  attributes [:email, :name]
  has_many :teams, link: :teams_link

  def teams_link(user, conn) do
    user_teams_url(conn, :index, user.id)
  end
end

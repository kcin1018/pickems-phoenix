defmodule Pickems.AuthErrorHandler do
 use Pickems.Web, :controller

 def unauthenticated(conn, _) do
  conn
   |> put_status(401)
   |> render(Pickems.ErrorView, "401.json")
 end

 def unauthorized(conn, _) do
  conn
   |> put_status(403)
   |> render(Pickems.ErrorView, "403.json")
 end
end

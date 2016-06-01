defmodule Pickems.Router do
  use Pickems.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  # Authenticated Requests
  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/api", Pickems do
    pipe_through :api

    post "register", AuthController, :register
    post "token", AuthController, :token
  end

  scope "/api", Pickems do
    pipe_through :api_auth

    get "/users/current", UserController, :current
  end
end

defmodule Pickems.Router do
  use Pickems.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  # Authenticated Requests
  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
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
    resources "users", UserController, only: [:show, :index] do
      get "teams", TeamController, :index, as: :teams
    end
    resources "teams", TeamController, except: [:new, :edit]
  end
end

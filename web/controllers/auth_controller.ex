defmodule Pickems.AuthController do
  use Pickems.Web, :controller

  alias Pickems.User

  import Ecto.Query, only: [where: 2]
  import Comeonin.Bcrypt
  import Logger

  def register(conn, %{"data" => %{"type" => "users",
    "attributes" => %{"email" => email,
      "name" => name,
      "password" => password,
      "password-confirmation" => password_confirmation}}}) do

    changeset = User.changeset %User{}, %{email: String.downcase(email),
      name: name,
      password_confirmation: password_confirmation,
      password: password}

    case Repo.insert changeset do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(Pickems.UserView, "show.json", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Pickems.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def token(conn, %{"grant_type" => "password",
    "username" => username,
    "password" => password}) do

    try do
      username = String.downcase(username)
      # Attempt to retrieve exactly one user from the DB, whose
      #   email matches the one provided with the login request
      user = User
      |> where(email: ^username)
      |> Repo.one!
      cond do

        checkpw(password, user.password_hash) ->
          # Successful login
          Logger.info "User " <> username <> " just logged in"
          # Encode a JWT
          { :ok, jwt, _} = Guardian.encode_and_sign(user, :token)
          conn
          |> json(%{access_token: jwt}) # Return token to the client

        true ->
          # Unsuccessful login
          Logger.warning "User " <> username <> " just failed to login"
          conn
          |> put_status(401)
          |> render(Pickems.ErrorView, "401.json") # 401
      end
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging
        Logger.error "Unexpected error while attempting to login user " <> username
        conn
        |> put_status(401)
        |> render(Pickems.ErrorView, "401.json") # 401
    end
  end

  def token(conn, %{"grant_type" => _}) do
    ## Handle unknown grant type
    conn
    |> put_status(401)
    |> render(Pickems.ErrorView, "401.json") # 401
  end
end

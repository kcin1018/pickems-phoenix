defmodule Pickems.UserControllerTest do
  use Pickems.ConnCase

  alias Pickems.User

  @valid_attrs %{
    email: "testuser@example.com",
    name: "Test User",
    password: "fqhi12hrrfasf",
    "password-confirmation": "fqhi12hrrfasf"
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
    regConn = conn
    # create a user to make login request with
    regConn = post regConn, auth_path(regConn, :register), %{data: %{type: "users", attributes: @valid_attrs }}
    regConn = post regConn, auth_path(regConn, :token), @valid_token
    token = json_response(regConn, 200)["access_token"]

    conn = put_req_header(conn, "authorization", "Bearer " <> token)
    conn = get conn, user_path(conn, :current)
    assert json_response(conn, 200)["data"]["id"]
    assert json_response(conn, 200)["data"]["type"] == "users"
  end

end

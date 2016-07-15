defmodule Pickems.AuthControllerTest do
  use Pickems.ConnCase

  alias Pickems.User

  @valid_attrs %{
    email: "testuser@example.com",
    name: "Test User",
    password: "fqhi12hrrfasf",
    "password-confirmation": "fqhi12hrrfasf",
    admin: false
  }

  @invalid_attrs %{}

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

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, auth_path(conn, :register), %{data: %{type: "users",
      attributes: @valid_attrs
      }}
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, %{email: @valid_attrs[:email]})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, auth_path(conn, :register),  %{data: %{type: "users",
      attributes: @invalid_attrs
    }}
    assert json_response(conn, 422)["errors"]
  end

  test "displays unsupported grant type for invalid token request", %{conn: conn} do
    conn = post conn, auth_path(conn, :token), @invalid_token
    assert json_response(conn, 401)["errors"]
  end

  test "displays access_token on successful login", %{conn: conn} do
    # create a user to make login request with
    conn = post conn, auth_path(conn, :register), %{data: %{type: "users", attributes: @valid_attrs }}
    conn = post conn, auth_path(conn, :token), @valid_token
    assert json_response(conn, 200)["access_token"]
  end

end

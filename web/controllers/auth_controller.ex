defmodule TheLeanCafe.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use TheLeanCafe.Web, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  require IEx

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(conn, _params) do
    user = %{avatar: conn.assigns.ueberauth_auth.info.urls.avatar_url, name: conn.assigns.ueberauth_auth.info.name,
        nickname: conn.assigns.ueberauth_auth.info.nickname}

    conn
    |> put_flash(:success, "Authenticaed!")
    |> put_session(:current_user, user)
    |> redirect(to: "/")
  end

end

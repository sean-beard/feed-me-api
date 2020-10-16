defmodule FeedMeWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use FeedMeWeb, :controller
  plug(Ueberauth)

  alias FeedMe.Account.User
  alias FeedMe.Repo

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    changeset =
      User.changeset(%User{}, %{
        name: auth.info.nickname,
        email: auth.info.email,
        token: auth.credentials.token,
        provider: "github"
      })

    sign_in(conn, changeset)
  end

  @spec logout(Plug.Conn.t(), any) :: Plug.Conn.t()
  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  defp sign_in(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: "/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: "/")
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end

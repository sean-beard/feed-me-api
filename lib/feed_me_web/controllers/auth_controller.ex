defmodule FeedMeWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use FeedMeWeb, :controller
  plug(Ueberauth)

  alias FeedMe.Account
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

  def callback(%{assigns: %{ueberauth_failure: %{errors: _errors}}} = conn, _params) do
    IO.puts("Error authenticating via Ueberauth...")

    conn
    |> send_resp(
      :internal_server_error,
      Jason.encode!(%{status: 500, message: "Error signing in."})
    )
  end

  @spec logout(Plug.Conn.t(), any) :: Plug.Conn.t()
  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> send_resp(:ok, Jason.encode!(%{status: 200, message: "Successfully signed out."}))
  end

  defp sign_in(conn, changeset) do
    case Account.insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> send_resp(
          :ok,
          Jason.encode!(%{
            status: 200,
            message: "Successfully signed in.",
            user: %{
              name: user.name,
              email: user.email,
              token: user.token
            }
          })
        )

      {:error, _reason} ->
        conn
        |> send_resp(
          :internal_server_error,
          Jason.encode!(%{status: 500, message: "Error signing in."})
        )
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

defmodule FeedMeWeb.AccountController do
  use FeedMeWeb, :controller

  alias FeedMe.Account

  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug(FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer")

  def get_account(conn, _params) do
    user_id = conn.assigns.user.id

    case Account.get_account(user_id) do
      {:ok, account_dto} ->
        Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, account: account_dto}))

      :error ->
        Conn.send_resp(
          conn,
          :not_found,
          Jason.encode!(%{status: 404, message: "Error getting user with ID #{user_id}"})
        )
    end
  end
end

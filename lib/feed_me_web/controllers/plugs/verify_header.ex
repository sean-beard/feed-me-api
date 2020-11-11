defmodule FeedMeWeb.Plugs.VerifyHeader do
  @moduledoc """
  This plug is used to set the authenticated user.
  """

  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    case Enum.into(conn.req_headers, %{}) do
      %{"authorization" => authorization} ->
        [_bearer, token] = String.split(authorization, " ")
        user = FeedMe.Account.get_user_by_token(token)

        if user != nil do
          assign(conn, :user, user)
        else
          send_resp(
            conn,
            :unauthorized,
            Jason.encode!(%{status: 401, message: "Oops! You must be logged in to do that."})
          )
          |> halt()
        end

      _ ->
        send_resp(
          conn,
          :unauthorized,
          Jason.encode!(%{status: 401, message: "Oops! No Authorization header was sent."})
        )
        |> halt()
    end
  end
end

defmodule FeedMeWeb.Plugs.VerifyHeader do
  @moduledoc """
  This plug is used to set the authenticated user.
  """

  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    %{"authorization" => authorization} = Enum.into(conn.req_headers, %{})

    if authorization do
      [_bearer, token] = String.split(authorization, " ")
      user = FeedMe.Account.get_user_by_token(token)

      if user != nil do
        conn
      else
        send_resp(conn, :unauthorized, "Oops! You must be logged in to do that.")
        |> halt()
      end
    else
      send_resp(conn, :unauthorized, "Oops! You must be logged in to do that.")
      |> halt()
    end
  end
end
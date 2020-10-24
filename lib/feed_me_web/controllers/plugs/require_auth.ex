defmodule FeedMeWeb.Plugs.RequireAuth do
  @moduledoc """
  This plug is used to ensure the user in authenticated.
  """

  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      send_resp(conn, :unauthorized, "Oops! You must be logged in to do that.")
      |> halt()
    end
  end
end

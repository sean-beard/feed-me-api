defmodule FeedMeWeb.SubscriptionController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.RequireAuth

  def index(conn, _params) do
    subscriptions = AccountContent.list_subscriptions()
    Conn.send_resp(conn, :ok, Jason.encode!(subscriptions))
  end
end

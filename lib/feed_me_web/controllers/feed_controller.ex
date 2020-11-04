defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    feeds = Content.list_feeds()
    Conn.send_resp(conn, :ok, Jason.encode!(feeds))
  end

  def get_item(conn, %{"id" => id}) do
    item = Content.get_feed_item!(id)
    Conn.send_resp(conn, :ok, Jason.encode!(item))
  end
end

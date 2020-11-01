defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    feeds =
      Content.list_feeds()
      |> Enum.map(fn feed ->
        items = Content.get_feed_items_from_rss_url(feed.url)
        Map.put(feed, :items, items)
      end)

    Conn.send_resp(conn, :ok, Jason.encode!(feeds))
  end
end

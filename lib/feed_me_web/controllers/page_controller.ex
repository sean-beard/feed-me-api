defmodule FeedMeWeb.PageController do
  use FeedMeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

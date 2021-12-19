defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug(FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer")

  def index(conn, %{"numItems" => num_items}) do
    num_items_integer = String.to_integer(num_items)
    feed = conn.assigns.user.id |> Content.list_feed() |> Enum.take(num_items_integer)

    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, feed: feed}))
  end

  def index(conn, _params) do
    feed = Content.list_feed(conn.assigns.user.id)
    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, feed: feed}))
  end

  def get_item(conn, %{"id" => feed_item_id}) do
    user = conn.assigns.user

    item =
      Content.get_feed_item!(feed_item_id)
      |> Content.get_feed_item_dto(user)

    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, item: item}))
  end

  def update_item_statuses(conn, %{"items" => client_items}) do
    AccountContent.create_or_update_feed_item_statuses(conn.assigns.user.id, client_items)

    Conn.send_resp(
      conn,
      :ok,
      Jason.encode!(%{status: 200, message: "Success"})
    )
  end
end

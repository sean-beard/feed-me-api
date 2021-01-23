defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    user = conn.assigns.user

    feeds_json =
      AccountContent.list_subscriptions(user.id)
      |> Enum.map(fn %{feed_id: feed_id} -> feed_id end)
      |> Content.list_feeds()
      |> Enum.map(fn feed -> Content.convert_db_feed_to_json_feed(feed, user) end)

    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, feeds: feeds_json}))
  end

  def get_item(conn, %{"id" => feed_item_id}) do
    user = conn.assigns.user

    item =
      Content.get_feed_item!(feed_item_id, user.id)
      |> Content.convert_db_item_to_json_item(user)

    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, item: item}))
  end

  def update_item_statuses(conn, %{"items" => items}) do
    user_id = conn.assigns.user.id

    items
    |> Enum.each(fn %{"id" => item_id, "isRead" => is_read} ->
      create_or_update_feed_item_status(conn, item_id, user_id, is_read)
    end)

    Conn.send_resp(
      conn,
      :ok,
      Jason.encode!(%{status: 200, message: "Success"})
    )
  end

  defp create_or_update_feed_item_status(conn, feed_item_id, user_id, is_read) do
    item = Content.get_feed_item!(feed_item_id, user_id)
    AccountContent.create_feed_item_status(item, conn.assigns.user, is_read)
  end
end

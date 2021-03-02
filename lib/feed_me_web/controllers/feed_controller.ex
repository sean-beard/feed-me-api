defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    feed = Content.list_feed(conn.assigns.user.id)
    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, feed: feed}))
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
    AccountContent.create_feed_item_status(item, conn.assigns.user, %{is_read: is_read})
  end
end

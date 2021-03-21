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
      |> Content.get_feed_item_dto(user)

    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, item: item}))
  end

  def update_item_statuses(conn, %{"items" => items}) do
    user_id = conn.assigns.user.id

    items
    |> Enum.each(fn %{"id" => item_id} = item ->
      current_time_sec =
        case item["currentTime"] do
          nil ->
            # We don't want to set `current_time_sec` to `nil` when updating only `is_read`
            AccountContent.get_feed_item_status(item_id, user_id)
            |> Enum.at(0, %{})
            |> Map.get(:current_time_sec)

          time ->
            time
        end

      attrs = %{
        is_read: item["isRead"],
        current_time_sec: current_time_sec
      }

      create_or_update_feed_item_status(conn, item_id, user_id, attrs)
    end)

    Conn.send_resp(
      conn,
      :ok,
      Jason.encode!(%{status: 200, message: "Success"})
    )
  end

  defp create_or_update_feed_item_status(conn, feed_item_id, user_id, attrs) do
    item = Content.get_feed_item!(feed_item_id, user_id)
    AccountContent.create_feed_item_status(item, conn.assigns.user, attrs)
  end
end

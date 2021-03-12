defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug(FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer")

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

  def update_item_statuses(conn, %{"items" => items}) do
    items
    |> Enum.each(fn %{"id" => item_id} = item ->
      attrs =
        case item["currentTime"] do
          nil ->
            %{is_read: item["isRead"]}

          time ->
            %{is_read: item["isRead"], current_time_sec: time}
        end

      create_or_update_feed_item_status(conn.assigns.user, item_id, attrs)
    end)

    Conn.send_resp(
      conn,
      :ok,
      Jason.encode!(%{status: 200, message: "Success"})
    )
  end

  defp create_or_update_feed_item_status(user, feed_item_id, attrs) do
    item = Content.get_feed_item!(feed_item_id)
    AccountContent.create_feed_item_status(item, user, attrs)
  end
end

defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias FeedMe.Content.FeedItem
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    user_id = conn.assigns.user.id

    feeds =
      AccountContent.list_subscriptions(user_id)
      |> Enum.map(fn %{feed_id: feed_id} -> feed_id end)
      |> Content.list_feeds(user_id)
      |> Enum.map(&Content.convert_db_feed_to_json_feed/1)

    Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, feeds: feeds}))
  end

  def get_item(conn, %{"id" => feed_item_id}) do
    item =
      Content.get_feed_item!(feed_item_id, conn.assigns.user.id)
      |> Content.convert_db_item_to_json_item()

    case item.isRead do
      nil ->
        case create_status(conn, item, false) do
          nil ->
            Conn.send_resp(
              conn,
              :internal_server_error,
              Jason.encode!(%{
                status: 500,
                message: "Error getting feed item status"
              })
            )

          status ->
            encoded_item =
              Map.put(item, :isRead, status.is_read)
              |> Jason.encode!()

            Conn.send_resp(
              conn,
              :ok,
              Jason.encode!(%{
                status: 200,
                item: encoded_item
              })
            )
        end

      _is_read ->
        Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, item: item}))
    end
  end

  # TODO: look into upsert here
  def update_item_status(conn, %{"id" => feed_item_id, "isRead" => is_read}) do
    case AccountContent.get_feed_item_status(feed_item_id) do
      nil ->
        IO.puts("No feed item status found for ID #{feed_item_id}")

        item = Content.get_feed_item!(feed_item_id, conn.assigns.user.id)

        case create_status(conn, item, is_read) do
          nil ->
            Conn.send_resp(
              conn,
              :internal_server_error,
              Jason.encode!(%{
                status: 500,
                message: "Error updating feed item status"
              })
            )

          status ->
            Conn.send_resp(
              conn,
              :ok,
              Jason.encode!(%{status: 200, isRead: status.is_read})
            )
        end

      status = %AccountContent.FeedItemStatus{} ->
        IO.puts("Feed item status found for ID #{feed_item_id}")
        update_status(conn, status, is_read)

      _error ->
        IO.puts("Error getting feed item status for ID #{feed_item_id}")

        Conn.send_resp(
          conn,
          :internal_server_error,
          Jason.encode!(%{
            status: 500,
            message: "Error updating feed item status"
          })
        )
    end
  end

  defp update_status(conn, status, is_read) do
    IO.puts("Updating feed item status...")

    case AccountContent.update_feed_item_status(status, %{is_read: is_read}) do
      {:ok, status} ->
        Conn.send_resp(
          conn,
          :ok,
          Jason.encode!(%{status: 200, message: "Success", isRead: status.is_read})
        )

      {:error, _changeset} ->
        Conn.send_resp(
          conn,
          :internal_server_error,
          Jason.encode!(%{
            status: 500,
            message: "Error updating feed item status"
          })
        )
    end
  end

  defp create_status(conn, %FeedItem{} = item, is_read) do
    IO.puts("Creating new feed item status...")

    case AccountContent.create_feed_item_status(item, conn.assigns.user, is_read) do
      {:ok, status} ->
        status

      {:error, _changeset} ->
        IO.puts("Error creating feed item status for ID #{item.id}")
        nil
    end
  end
end

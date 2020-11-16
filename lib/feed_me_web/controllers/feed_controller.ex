defmodule FeedMeWeb.FeedController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    feeds =
      AccountContent.list_subscriptions(conn.assigns.user.id)
      |> Enum.map(fn %{feed_id: feed_id} -> feed_id end)
      |> Content.list_feeds()
      |> Enum.map(&Content.convert_db_feed_to_json_feed/1)

    Conn.send_resp(conn, :ok, Jason.encode!(feeds))
  end

  def get_item(conn, %{"id" => feed_item_id}) do
    item =
      Content.get_feed_item!(feed_item_id, conn.assigns.user.id)
      |> Content.convert_db_item_to_json_item()

    case item.isRead do
      nil ->
        case AccountContent.create_feed_item_status(item, conn.assigns.user, false) do
          {:ok, status} ->
            encoded_item =
              Map.put(item, :isRead, status.is_read)
              |> Jason.encode!()

            Conn.send_resp(conn, :ok, encoded_item)

          {:error, _changeset} ->
            IO.puts("Error creating feed item status for ID #{feed_item_id}")
            Conn.send_resp(conn, :internal_server_error, "Error getting feed item status")
        end

      _is_read ->
        Conn.send_resp(conn, :ok, Jason.encode!(item))
    end
  end

  def update_item_status(conn, %{"id" => feed_item_id, "isRead" => is_read}) do
    case AccountContent.get_feed_item_status(feed_item_id) do
      nil ->
        IO.puts("No feed item status found for ID #{feed_item_id}")
        create_feed_item_status(conn, feed_item_id, is_read)

      status = %AccountContent.FeedItemStatus{} ->
        IO.puts("Feed item status found for ID #{feed_item_id}")
        update_feed_item_status(conn, feed_item_id, status, is_read)

      _error ->
        IO.puts("Error getting feed item status for ID #{feed_item_id}")
        Conn.send_resp(conn, :internal_server_error, "Error updating feed item status")
    end
  end

  defp update_feed_item_status(conn, feed_item_id, status, is_read) do
    IO.puts("Updating feed item status...")

    case AccountContent.update_feed_item_status(status, %{is_read: is_read}) do
      {:ok, status} ->
        Conn.send_resp(
          conn,
          :ok,
          Jason.encode!(%{status: 200, message: "Success", isRead: status.is_read})
        )

      {:error, _changeset} ->
        IO.puts("Error updating feed item status for ID #{feed_item_id}")
        Conn.send_resp(conn, :internal_server_error, "Error updating feed item status")
    end
  end

  defp create_feed_item_status(conn, feed_item_id, is_read) do
    IO.puts("Creating new feed item status...")
    item = Content.get_feed_item!(feed_item_id, conn.assigns.user.id)

    case AccountContent.create_feed_item_status(item, conn.assigns.user, is_read) do
      {:ok, status} ->
        Conn.send_resp(
          conn,
          :ok,
          Jason.encode!(%{status: 200, message: "Success", isRead: status.is_read})
        )

      {:error, _changeset} ->
        IO.puts("Error creating feed item status for ID #{feed_item_id}")
        Conn.send_resp(conn, :internal_server_error, "Error updating feed item status")
    end
  end
end

defmodule FeedMeWeb.SubscriptionController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.RequireAuth

  def index(conn, _params) do
    subscriptions = AccountContent.list_subscriptions()
    Conn.send_resp(conn, :ok, Jason.encode!(subscriptions))
  end

  def create(conn, %{"feed" => feed}) do
    case Content.create_feed(feed) do
      {:ok, feed} ->
        create_subscription(conn, feed)

      {:error, _feed_changeset} ->
        # TODO: check for unique constraint error properly
        IO.puts("Error creating new feed - probably already exists")
        %{"url" => url} = feed
        create_subscription(conn, Content.get_feed_by_url!(url))
    end
  end

  defp create_subscription(conn, feed) do
    case AccountContent.create_subscription(conn.assigns.user, feed) do
      {:ok, subscription} ->
        Conn.send_resp(conn, :ok, Jason.encode!(subscription))

      {:error, _subscription_changeset} ->
        Conn.send_resp(conn, :internal_server_error, "Error creating subscription")
    end
  end
end

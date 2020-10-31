defmodule FeedMeWeb.SubscriptionController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    subscriptions = AccountContent.list_subscriptions()
    Conn.send_resp(conn, :ok, Jason.encode!(subscriptions))
  end

  def create(conn, %{"url" => url}) do
    feed = Content.get_feed_from_rss_url(url)

    case Content.create_feed(feed) do
      {:ok, feed} ->
        create_subscription(conn, feed)

      {:error, feed_changeset} ->
        log_create_feed_error(feed_changeset.errors)
        create_subscription(conn, Content.get_feed_by_url!(url))
    end
  end

  defp create_subscription(conn, feed) do
    case AccountContent.create_subscription(conn.assigns.user, feed) do
      {:ok, subscription} ->
        Conn.send_resp(conn, :ok, Jason.encode!(subscription))

      {:error, subscription_changeset} ->
        log_create_subscription_error(subscription_changeset.errors)
        Conn.send_resp(conn, :internal_server_error, "Error creating subscription")
    end
  end

  defp log_create_feed_error(errors) do
    [email: {_message, [constraint: constraint_type, constraint_name: _name]}] = errors
    log_create_error(constraint_type, "feed")
  end

  defp log_create_subscription_error(errors) do
    [user_id: {_message, [constraint: constraint_type, constraint_name: _name]}] = errors
    log_create_error(constraint_type, "subscription")
  end

  defp log_create_error(constraint_type, name) do
    if constraint_type == :unique do
      IO.puts("Error creating new #{name}: #{name} already exists.")
    else
      IO.puts("Error creating new #{name}.")
    end
  end
end

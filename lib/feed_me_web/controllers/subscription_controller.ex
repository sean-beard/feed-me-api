defmodule FeedMeWeb.SubscriptionController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def create(conn, %{"url" => url}) do
    feed = Content.get_feed_from_rss_url(url)

    case Content.create_feed(feed) do
      {:ok, feed} ->
        Content.insert_all_feed_items(feed)
        create_subscription(conn, feed)

      {:error, feed_changeset} ->
        if get_feed_constraint_type(feed_changeset.errors) == :unique do
          IO.puts("Feed already exists. Creating subscription...")
          create_subscription(conn, Content.get_feed_by_url!(url))
        else
          IO.puts("Error creating new feed from url: #{url}")
          Conn.send_resp(conn, :internal_server_error, "Error creating feed")
        end
    end
  end

  defp create_subscription(conn, feed) do
    case AccountContent.create_subscription(conn.assigns.user, feed) do
      {:ok, _subscription} ->
        Conn.send_resp(
          conn,
          :ok,
          Jason.encode!(%{status: 200, message: "Successfully subscribed!"})
        )

      {:error, subscription_changeset} ->
        constraint_type = get_subscription_constraint_type(subscription_changeset.errors)

        if constraint_type == :unique do
          IO.puts("Subscription already exists.")
          Conn.send_resp(conn, :ok, Jason.encode!(%{status: 200, message: "Already subscribed"}))
        else
          IO.puts("Error creating new subscription for feed #{feed.id}")
          Conn.send_resp(conn, :internal_server_error, "Error creating subscription")
        end
    end
  end

  defp get_subscription_constraint_type(errors) do
    [user_id: {_message, [constraint: constraint_type, constraint_name: _name]}] = errors
    constraint_type
  end

  defp get_feed_constraint_type(errors) do
    [email: {_message, [constraint: constraint_type, constraint_name: _name]}] = errors
    constraint_type
  end
end

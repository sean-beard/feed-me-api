defmodule FeedMeWeb.SubscriptionController do
  use FeedMeWeb, :controller

  alias FeedMe.AccountContent
  alias FeedMe.Content
  alias FeedMe.RssUtils
  alias Plug.Conn

  # This plug will execute before every handler in this list
  plug FeedMeWeb.Plugs.VerifyHeader, realm: "Bearer"

  def index(conn, _params) do
    subscriptions = AccountContent.get_subscription_dtos(conn.assigns.user.id)

    Conn.send_resp(
      conn,
      :ok,
      Jason.encode!(%{status: 200, subscriptions: subscriptions})
    )
  end

  def subscribe(conn, %{"url" => url}) do
    case RssUtils.get_feed_from_rss_url(url) do
      nil ->
        Conn.send_resp(
          conn,
          :unsupported_media_type,
          Jason.encode!(%{status: 415, message: "Unsupported RSS feed format."})
        )

      feed ->
        create_feed_and_subscription(conn, url, feed)
    end
  end

  def unsubscribe(conn, %{"subscriptionId" => subscription_id}) do
    subscription = AccountContent.get_subscription!(subscription_id)
    update_subscription(conn, subscription, %{is_subscribed: false})
  end

  defp create_feed_and_subscription(conn, url, feed) do
    case Content.create_feed(feed) do
      {:ok, feed} ->
        update_or_create_subscription(conn, feed)

      {:error, feed_changeset} ->
        if get_feed_constraint_type(feed_changeset.errors) == :unique do
          IO.puts("Feed already exists. Creating subscription...")
          update_or_create_subscription(conn, Content.get_feed_by_url!(url))
        else
          IO.puts("Error creating new feed from url: #{url}")

          Conn.send_resp(
            conn,
            :internal_server_error,
            Jason.encode!(%{status: 500, message: "Error creating feed"})
          )
        end
    end
  end

  defp update_or_create_subscription(conn, feed) do
    case AccountContent.get_subscription(feed.id, conn.assigns.user.id) do
      [subscription = %AccountContent.Subscription{}] ->
        update_subscription(conn, subscription, %{is_subscribed: true})

      [] ->
        Content.insert_all_feed_items(feed)
        create_subscription(conn, feed)
    end
  end

  defp update_subscription(conn, subscription, attrs) do
    case AccountContent.update_subscription(subscription, attrs) do
      {:ok, _subscription} ->
        Conn.send_resp(
          conn,
          :ok,
          Jason.encode!(%{status: 200, message: "Successfully updated subscription!"})
        )

      {:error, _changeset} ->
        Conn.send_resp(
          conn,
          :internal_server_error,
          Jason.encode!(%{status: 500, message: "Error updating subscription #{subscription.id}"})
        )
    end
  end

  defp create_subscription(conn, feed) do
    user = conn.assigns.user

    case AccountContent.create_subscription(user, feed) do
      {:ok, _subscription} ->
        AccountContent.create_feed_item_statuses(user.id, feed)

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

          Conn.send_resp(
            conn,
            :internal_server_error,
            Jason.encode!(%{status: 500, message: "Error creating subscription"})
          )
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

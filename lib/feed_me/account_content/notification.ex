defmodule FeedMe.AccountContent.Notification do
  @moduledoc """
  This module saves and sends push notifications.
  """

  import Ecto.Query, warn: false
  alias FeedMe.AccountContent.NotificationSubscription
  alias FeedMe.Repo

  @doc """
  Returns a list of user notification subscriptions.

  ## Examples

      iex> list_notification_subscriptions(user_id)
      [%NotificationSubscription{}, ...]

  """
  def list_notification_subscriptions(user_id) do
    NotificationSubscription
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  @doc """
  Creates a notification subscription for a user.

  ## Examples

      iex> create_notification_subscription(user, %{field: value})
      {:ok, %NotificationSubscription{}}

      iex> create_notification_subscription(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification_subscription(user, attrs \\ %{}) do
    %NotificationSubscription{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:user, user)
    |> NotificationSubscription.changeset(attrs)
    |> Repo.insert()
  end

  def get_unread_item_count_by_user() do
    query = """
      select
        user_id,
        count(*) as num_unread_items
      from
        feed_item_statuses
      where
        is_read IS FALSE
      group by user_id
    """

    case Repo.query(query) do
      {:ok, result = %Postgrex.Result{}} ->
        IO.puts("Found #{result.num_rows} users with unread items...")

        result.rows
        |> Enum.map(fn [user_id, num_unread_items] ->
          %{user_id: user_id, num_unread_items: num_unread_items}
        end)

      _error ->
        []
    end
  end

  def get_new_unread_item_count_by_user(start_unread_item_counts, end_unread_item_counts) do
    end_unread_item_counts
    |> Enum.map(fn %{user_id: user_id, num_unread_items: end_count} ->
      get_new_unread_item_count(user_id, end_count, start_unread_item_counts)
    end)
    |> Enum.filter(fn row -> row != nil end)
  end

  # from client model to web push model
  def get_valid_subscription(%{
        "endpoint" => endpoint,
        "expirationTime" => expiration_time,
        "keys" => %{"p256dh" => p256dh, "auth" => auth}
      }) do
    keys = %{p256dh: p256dh, auth: auth}

    %{endpoint: endpoint, keys: keys, expiration_time: expiration_time}
  end

  # from DB model to web push model
  def get_valid_subscription(%NotificationSubscription{} = subscription) do
    keys = %{p256dh: subscription.p256dh, auth: subscription.auth}

    %{
      endpoint: subscription.endpoint,
      keys: keys,
      expiration_time: subscription.expiration_time
    }
  end

  def get_valid_subscription() do
    raise "Cannot send a notification without a subscription."
  end

  def get_valid_subscription(_anything) do
    raise "Subscription not formatted properly."
  end

  def send_notifications(%{user_id: user_id, num_unread_items: num_unread_items}) do
    IO.puts("Starting job to send notifications to user #{user_id}...")

    subs = list_notification_subscriptions(user_id)

    IO.puts("Found #{Enum.count(subs)} notification subscriptions...")

    for sub <- subs do
      valid_sub = get_valid_subscription(sub)

      body =
        ~s({"title": "New Feed Items", "body": "You have #{num_unread_items} new feed items!", "url": "#{sub.origin}/"})

      send(%{body: body, subscription: valid_sub})
    end

    IO.puts("Done sending notifications...")
  end

  defp get_new_unread_item_count(user_id, end_count, start_unread_item_counts) do
    case Enum.find(start_unread_item_counts, fn row -> row.user_id == user_id end) do
      nil ->
        nil

      start_count_row ->
        start_count = start_count_row.num_unread_items
        new_unread_item_count = end_count - start_count

        if new_unread_item_count > 0 do
          %{user_id: user_id, num_unread_items: new_unread_item_count}
        else
          nil
        end
    end
  end

  defp send(%{body: body, subscription: subscription}) do
    WebPushEncryption.send_web_push(body, subscription)
  end
end

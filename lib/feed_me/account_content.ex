defmodule FeedMe.AccountContent do
  @moduledoc """
  The AccountContent context.
  """

  import Ecto.Query, warn: false
  alias FeedMe.Repo

  alias FeedMe.AccountContent.Subscription

  @doc """
  Returns a list of all subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions do
    Repo.all(Subscription)
  end

  @doc """
  Returns a list of user subscriptions.

  ## Examples

      iex> list_subscriptions(user_id)
      [%Subscription{}, ...]

  """
  def list_subscriptions(user_id) do
    Subscription
    |> where(user_id: ^user_id)
    |> Repo.all()
    |> Enum.filter(fn sub -> sub.is_subscribed end)
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  def get_subscription(feed_id, user_id) do
    Repo.all(
      from(s in Subscription,
        where: s.feed_id == ^feed_id and s.user_id == ^user_id,
        select: s
      )
    )
  end

  @doc """
  Creates a feed subscription for a user.

  ## Examples

      iex> create_subscription(user, feed)
      {:ok, %Subscription{}}

      iex> create_subscription(user, bad_feed)
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(user, feed) do
    feed
    |> Ecto.build_assoc(:subscriptions)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Subscription.changeset(%{is_subscribed: true})
    |> Repo.insert()
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> change_subscription(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end

  def convert_subscription_to_json(subscription) do
    subscription
    |> Map.put(:isSubscribed, subscription.is_subscribed)
    |> Map.put(:feedName, subscription.feed.name)
  end

  alias FeedMe.AccountContent.FeedItemStatus

  @doc """
  Returns the list of feed_item_statuses.

  ## Examples

      iex> list_feed_item_statuses()
      [%FeedItemStatus{}, ...]

  """
  def list_feed_item_statuses do
    Repo.all(FeedItemStatus)
  end

  def get_feed_item_status(feed_item_id, user_id) do
    # TODO: update this to Repo.one
    Repo.all(
      from(s in FeedItemStatus,
        where: s.feed_item_id == ^feed_item_id and s.user_id == ^user_id,
        select: s
      )
    )
  end

  @doc """
  Creates a feed_item_status or updates an existing status.

  ## Examples

      iex> create_feed_item_status(feed_item, user, is_read)
      {:ok, %FeedItemStatus{}}

      iex> create_feed_item_status(bad_feed_item, user, is_read)
      {:error, %Ecto.Changeset{}}

  """
  def create_feed_item_status(feed_item, user, attrs) do
    on_conflict_set =
      if Map.has_key?(attrs, :current_time_sec) do
        [is_read: attrs.is_read, current_time_sec: attrs.current_time_sec]
      else
        [is_read: attrs.is_read]
      end

    feed_item
    |> Ecto.build_assoc(:feed_item_statuses)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:user, user)
    |> FeedItemStatus.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: on_conflict_set],
      conflict_target: [:user_id, :feed_item_id]
    )
  end

  # TODO FeedItemStatus type assertions?
  def create_or_update_feed_item_statuses(user_id, client_items) do
    get_db_statuses_from_client_items(client_items, user_id)
    |> update_item_statuses
  end

  @doc """
  Updates a feed_item_status.

  ## Examples

      iex> update_feed_item_status(feed_item_status, %{field: new_value})
      {:ok, %FeedItemStatus{}}

      iex> update_feed_item_status(feed_item_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feed_item_status(%FeedItemStatus{} = feed_item_status, attrs) do
    feed_item_status
    |> FeedItemStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feed_item_status.

  ## Examples

      iex> delete_feed_item_status(feed_item_status)
      {:ok, %FeedItemStatus{}}

      iex> delete_feed_item_status(feed_item_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feed_item_status(%FeedItemStatus{} = feed_item_status) do
    Repo.delete(feed_item_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feed_item_status changes.

  ## Examples

      iex> change_feed_item_status(feed_item_status)
      %Ecto.Changeset{data: %FeedItemStatus{}}

  """
  def change_feed_item_status(%FeedItemStatus{} = feed_item_status, attrs \\ %{}) do
    FeedItemStatus.changeset(feed_item_status, attrs)
  end

  def insert_feed_item_statuses(user, feed) do
    feed_with_items = feed |> Repo.preload(:feed_items)

    Enum.each(feed_with_items.feed_items, fn item ->
      create_feed_item_status(item, user, %{is_read: false})
    end)
  end

  defp get_db_statuses_from_client_items(items, user_id) do
    items
    |> Enum.map(fn %{"id" => item_id} = item ->
      # Repo.insert_all doesn't support auto timestamps
      utc_now =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.truncate(:second)

      base_status = %{
        user_id: user_id,
        feed_item_id: item_id,
        is_read: item["isRead"],
        inserted_at: utc_now,
        updated_at: utc_now
      }

      case item["currentTime"] do
        nil ->
          existing_current_time =
            get_feed_item_status(item_id, user_id)
            |> Enum.at(0, %{})
            |> Map.get(:current_time_sec)

          Map.put(base_status, :current_time_sec, existing_current_time)

        time ->
          Map.put(base_status, :current_time_sec, time)
      end
    end)
  end

  defp update_item_statuses(statuses) do
    Repo.insert_all(FeedItemStatus, statuses,
      on_conflict: {:replace, [:is_read, :current_time_sec, :updated_at]},
      conflict_target: [:user_id, :feed_item_id]
    )
  end
end

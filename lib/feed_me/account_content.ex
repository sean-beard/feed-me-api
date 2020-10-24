defmodule FeedMe.AccountContent do
  @moduledoc """
  The AccountContent context.
  """

  import Ecto.Query, warn: false
  alias FeedMe.Repo

  alias FeedMe.AccountContent.Subscription

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions do
    Repo.all(Subscription)
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

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
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
    |> Subscription.changeset(attrs)
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

  @doc """
  Gets a single feed_item_status.

  Raises `Ecto.NoResultsError` if the Feed item status does not exist.

  ## Examples

      iex> get_feed_item_status!(123)
      %FeedItemStatus{}

      iex> get_feed_item_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feed_item_status!(id), do: Repo.get!(FeedItemStatus, id)

  @doc """
  Creates a feed_item_status.

  ## Examples

      iex> create_feed_item_status(%{field: value})
      {:ok, %FeedItemStatus{}}

      iex> create_feed_item_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feed_item_status(attrs \\ %{}) do
    %FeedItemStatus{}
    |> FeedItemStatus.changeset(attrs)
    |> Repo.insert()
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
end

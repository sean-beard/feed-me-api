defmodule FeedMe.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias FeedMe.AccountContent
  alias FeedMe.AccountContent.FeedItemStatus
  alias FeedMe.Content.Feed
  alias FeedMe.Content.FeedItem
  alias FeedMe.Repo
  alias HTTPoison.Response

  @doc """
  Returns the list of feeds.

  ## Examples

      iex> list_feeds()
      [%Feed{}, ...]

  """
  def list_feeds(user_id) do
    feed_ids =
      AccountContent.list_subscriptions(user_id)
      |> Enum.map(fn %{feed_id: feed_id} -> feed_id end)

    query =
      from(
        f in Feed,
        # TODO: preload feed items here when cron job is set up
        where: f.id in ^feed_ids,
        select: f
      )

    Repo.all(query)
    |> Enum.map(fn feed ->
      insert_all_feed_items(feed)
      items = list_feed_items(feed.id, user_id)
      Map.put(feed, :items, items)
    end)
  end

  @doc """
  Gets a single feed.

  Raises `Ecto.NoResultsError` if the Feed does not exist.

  ## Examples

      iex> get_feed!(123)
      %Feed{}

      iex> get_feed!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feed!(id), do: Repo.get!(Feed, id)
  def get_feed_by_url!(url), do: Repo.get_by!(Feed, url: url)

  @doc """
  Creates a feed.

  ## Examples

      iex> create_feed(%{field: value})
      {:ok, %Feed{}}

      iex> create_feed(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feed(attrs \\ %{}) do
    %Feed{}
    |> Feed.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feed.

  ## Examples

      iex> update_feed(feed, %{field: new_value})
      {:ok, %Feed{}}

      iex> update_feed(feed, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feed(%Feed{} = feed, attrs) do
    feed
    |> Feed.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feed.

  ## Examples

      iex> delete_feed(feed)
      {:ok, %Feed{}}

      iex> delete_feed(feed)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feed(%Feed{} = feed) do
    Repo.delete(feed)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feed changes.

  ## Examples

      iex> change_feed(feed)
      %Ecto.Changeset{data: %Feed{}}

  """
  def change_feed(%Feed{} = feed, attrs \\ %{}) do
    Feed.changeset(feed, attrs)
  end

  alias FeedMe.Content.FeedItem

  def list_feed_items(feed_id, user_id) do
    FeedItem
    |> where(feed_id: ^feed_id)
    |> Repo.all()
    |> Repo.preload(feed_item_statuses: from(s in FeedItemStatus, where: s.user_id == ^user_id))
    |> Enum.map(fn item -> convert_db_item_to_json_item(item) end)
  end

  @doc """
  Gets a single feed_item.

  Raises `Ecto.NoResultsError` if the Feed item does not exist.

  ## Examples

      iex> get_feed_item!(123)
      %FeedItem{}

      iex> get_feed_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feed_item!(id, user_id) do
    Repo.get!(FeedItem, id)
    |> Repo.preload(feed_item_statuses: from(s in FeedItemStatus, where: s.user_id == ^user_id))
    |> convert_db_item_to_json_item
  end

  @doc """
  Creates a feed_item.

  ## Examples

      iex> create_feed_item(%{field: value})
      {:ok, %FeedItem{}}

      iex> create_feed_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feed_item(attrs \\ %{}) do
    %FeedItem{}
    |> FeedItem.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Updates a feed_item.

  ## Examples

      iex> update_feed_item(feed_item, %{field: new_value})
      {:ok, %FeedItem{}}

      iex> update_feed_item(feed_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feed_item(%FeedItem{} = feed_item, attrs) do
    feed_item
    |> FeedItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feed_item.

  ## Examples

      iex> delete_feed_item(feed_item)
      {:ok, %FeedItem{}}

      iex> delete_feed_item(feed_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feed_item(%FeedItem{} = feed_item) do
    Repo.delete(feed_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feed_item changes.

  ## Examples

      iex> change_feed_item(feed_item)
      %Ecto.Changeset{data: %FeedItem{}}

  """
  def change_feed_item(%FeedItem{} = feed_item, attrs \\ %{}) do
    FeedItem.changeset(feed_item, attrs)
  end

  def get_feed_from_rss_url(url) do
    %Response{body: body} = HTTPoison.get!(url)

    %{
      "rss" => %{
        "#content" => %{
          "channel" => %{
            "description" => description,
            # "item" => items,
            # "link" => link,
            "title" => name
          }
        }
      }
    } = XmlToMap.naive_map(body)

    %{
      name: name,
      url: url,
      description: description
    }
  end

  defp insert_all_feed_items(feed) do
    db_feed_items =
      get_feed_items_from_rss_url(feed.url)
      |> convert_rss_items_to_db_items(feed.id)

    Repo.insert_all(FeedItem, db_feed_items, on_conflict: :nothing)
  end

  defp get_feed_items_from_rss_url(url) do
    %Response{body: body} = HTTPoison.get!(url)

    %{
      "rss" => %{
        "#content" => %{
          "channel" => %{
            "item" => items
          }
        }
      }
    } = XmlToMap.naive_map(body)

    items
  end

  defp convert_db_item_to_json_item(item) do
    is_read =
      case Enum.at(item.feed_item_statuses, 0) do
        nil ->
          nil

        status ->
          status.is_read
      end

    item
    |> Map.drop([:feed_item_statuses])
    |> Map.put(:isRead, is_read)
    |> Map.put(:pubDate, item.pub_date)
    |> Map.drop([:pub_date])
    |> Map.put(:description, :erlang.binary_to_term(item.description))
  end

  defp convert_rss_items_to_db_items(items, feed_id) do
    Enum.map(items, fn %{
                         "title" => title,
                         "description" => description,
                         "link" => url,
                         "pubDate" => pub_date
                       } ->
      %{
        title: title,
        description: :erlang.term_to_binary(description, [:compressed]),
        url: url,
        pub_date: pub_date,
        feed_id: feed_id
      }
    end)
  end
end

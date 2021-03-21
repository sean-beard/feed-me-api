defmodule FeedMe.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias FeedMe.AccountContent
  alias FeedMe.AccountContent.FeedItemStatus
  alias FeedMe.Content.Feed
  alias FeedMe.Content.FeedItem
  alias FeedMe.Content.FeedItemDto
  alias FeedMe.Repo
  alias FeedMe.RssUtils

  def list_feed(user_id) do
    query = """
      select
        i.id,
        f.name as feed_name,
        i.title,
        i.description,
        i.url,
        s.is_read,
        s.current_time_sec,
        i.media_type,
        i.media_url,
        case
          when i.pub_date like '___, % ___ %' then to_date(i.pub_date, 'DY, DD Mon YYYY')
          when i.pub_date like '%-%-%' then to_date(i.pub_date, 'YYYY-MM-DD')
        end as pub_date
      from feed_items as i
      inner join feeds as f
        on i.feed_id = f.id
      left join feed_item_statuses as s
        on s.user_id = #{user_id} and s.feed_item_id = i.id
      where i.feed_id in (
        select s.feed_id from subscriptions as s
        where user_id = #{user_id} and is_subscribed = true
      )
      order by pub_date desc
    """

    case Repo.query(query) do
      {:ok, result = %Postgrex.Result{}} ->
        IO.puts("Found #{result.num_rows} feed items...")
        process_db_feed_result(result)

      _error ->
        []
    end
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

  @doc """
  Gets a single feed by URL.

  Raises `Ecto.NoResultsError` if the Feed does not exist.

  ## Examples

      iex> get_feed_by_url!("https://my.rss.feed.com/feed.xml")
      %Feed{}

      iex> get_feed_by_url!("")
      ** (Ecto.NoResultsError)

  """
  def get_feed_by_url!(url_input) do
    url = RssUtils.get_rss_url(url_input)
    Repo.get_by!(Feed, url: url)
  end

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

  @doc """
  Returns a list of feed items and their read/unread status.

  ## Examples

      iex> list_feed_items(feed_id, user_id)
      [%FeedItem{}, ...]

  """
  def list_feed_items(feed_id, user_id) do
    FeedItem
    |> where(feed_id: ^feed_id)
    |> Repo.all()
    |> Repo.preload(feed_item_statuses: from(s in FeedItemStatus, where: s.user_id == ^user_id))
  end

  @doc """
  Gets a single feed item.

  Raises `Ecto.NoResultsError` if the feed item does not exist.

  ## Examples

      iex> get_feed_item!(item_id)
      %FeedItem{}

      iex> get_feed_item!(missing_item_id)
      ** (Ecto.NoResultsError)

  """
  def get_feed_item!(id) do
    Repo.get!(FeedItem, id)
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

  def insert_all_feed_items(feed) do
    feed_items = RssUtils.get_feed_items_from_rss_url(feed.url, feed.id)
    Repo.insert_all(FeedItem, feed_items, on_conflict: :nothing)
  end

  def get_feed_item_dto(item, user) do
    status = get_feed_item_status(item, user)

    %FeedItemDto{
      id: item.id,
      title: item.title,
      description: :erlang.binary_to_term(item.description),
      url: item.url,
      isRead: status.is_read,
      currentTime: status.current_time_sec,
      mediaType: item.media_type,
      mediaUrl: item.media_url,
      pubDate: item.pub_date
    }
  end

  defp get_feed_item_dto(item_db_result) do
    case item_db_result do
      [
        {"id", id},
        {"feed_name", feed_name},
        {"title", title},
        {"description", desc_binary},
        {"url", url},
        {"is_read", is_read},
        {"current_time_sec", current_time_sec},
        {"media_type", media_type},
        {"media_url", media_url},
        {"pub_date", pub_date}
      ] ->
        %FeedItemDto{
          id: id,
          feedName: feed_name,
          title: title,
          description: :erlang.binary_to_term(desc_binary),
          url: url,
          isRead: is_read,
          currentTime: current_time_sec,
          mediaType: media_type,
          mediaUrl: media_url,
          pubDate: pub_date
        }

      _ ->
        IO.puts("Error processing feed data...")
        %FeedItemDto{}
    end
  end

  defp process_db_feed_result(result) do
    result.rows
    |> Enum.map(fn row -> Enum.zip(result.columns, row) end)
    |> Enum.map(&get_feed_item_dto/1)
  end

  defp get_feed_item_status(item, user) do
    case AccountContent.get_feed_item_status(item.id, user.id) do
      [] ->
        {:ok, %FeedItemStatus{} = status} =
          AccountContent.create_feed_item_status(item, user, %{is_read: false})

        status

      [status = %AccountContent.FeedItemStatus{}] ->
        status
    end
  end
end

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

  @doc """
  Gets a news feed given a user ID.

  ## Examples

      iex> list_feed(user_id)
      [%FeedItemDto{}, ...]

      iex> list_feed(invalid_user_id)
      []

  """
  def list_feed(user_id) do
    unread_feed = list_unread_feed(user_id)
    read_feed = list_read_feed(user_id)

    Enum.concat(unread_feed, read_feed)
  end

  def search_feed(user_id, search_term) do
    query = """
      SELECT
        i.id,
        f.name AS feed_name,
        i.title,
        i.description,
        i.url,
        s.is_read,
        s.current_time_sec,
        i.media_type,
        i.media_url,
        CASE
          WHEN i.pub_date LIKE '___, % ___ %' THEN to_timestamp(i.pub_date, 'Dy, DD Mon YYYY HH24:MI:SS')
          WHEN i.pub_date LIKE '%-%-%' THEN to_timestamp(i.pub_date, 'YYYY-MM-DD"T"HH24:MI:SS')
        END AS pub_date
      FROM
        feed_items AS i
        INNER JOIN feeds AS f ON i.feed_id = f.id
        LEFT JOIN feed_item_statuses AS s ON s.user_id = #{user_id} AND s.feed_item_id = i.id
      WHERE
        i.feed_id IN (
          SELECT s.feed_id FROM subscriptions AS s WHERE user_id = #{user_id} AND is_subscribed = TRUE
        )
        AND (
          i.title ILIKE '%' || '#{search_term}' || '%' OR
          f.name ILIKE '%' || '#{search_term}' || '%' OR
          encode(i.description, 'hex') ILIKE '%' || encode('#{search_term}', 'hex') || '%'
        )
      ORDER BY
        s.is_read ASC, pub_date DESC;
    """

    case Repo.query(query) do
      {:ok, result = %Postgrex.Result{}} ->
        IO.puts("Found #{result.num_rows} search results...")
        process_db_feed_result(result)

      _error ->
        []
    end
  end

  defp list_unread_feed(user_id) do
    query = """
      SELECT
        i.id,
        f.name AS feed_name,
        i.title,
        i.description,
        i.url,
        s.is_read,
        s.current_time_sec,
        i.media_type,
        i.media_url,
        CASE WHEN i.pub_date LIKE '___, % ___ %' THEN
          to_timestamp(i.pub_date, 'Dy, DD Mon YYYY HH24:MI:SS')
        WHEN i.pub_date LIKE '%-%-%' THEN
          to_timestamp(i.pub_date, 'YYYY-MM-DD"T"HH24:MI:SS')
        END AS pub_date
      FROM feed_items AS i
      INNER JOIN feeds AS f ON i.feed_id = f.id
      LEFT JOIN feed_item_statuses AS s ON s.user_id = #{user_id}
        AND s.feed_item_id = i.id
      WHERE
        i.feed_id in(
          SELECT
            s.feed_id FROM subscriptions AS s
          WHERE
            user_id = #{user_id}
            AND is_subscribed = TRUE)
        AND s.is_read IS FALSE
      ORDER BY pub_date DESC
    """

    case Repo.query(query) do
      {:ok, result = %Postgrex.Result{}} ->
        IO.puts("Found #{result.num_rows} unread feed items...")
        process_db_feed_result(result)

      _error ->
        []
    end
  end

  defp list_read_feed(user_id) do
    query = """
      SELECT
        i.id,
        f.name AS feed_name,
        i.title,
        i.description,
        i.url,
        s.is_read,
        s.current_time_sec,
        i.media_type,
        i.media_url,
        CASE WHEN i.pub_date LIKE '___, % ___ %' THEN
          to_timestamp(i.pub_date, 'Dy, DD Mon YYYY HH24:MI:SS')
        WHEN i.pub_date LIKE '%-%-%' THEN
          to_timestamp(i.pub_date, 'YYYY-MM-DD"T"HH24:MI:SS')
        END AS pub_date
      FROM feed_items AS i
      INNER JOIN feeds AS f ON i.feed_id = f.id
      LEFT JOIN feed_item_statuses AS s ON s.user_id = #{user_id}
        AND s.feed_item_id = i.id
      WHERE
        i.feed_id in(
          SELECT
            s.feed_id FROM subscriptions AS s
          WHERE
            user_id = #{user_id}
            AND is_subscribed = TRUE)
        AND s.is_read IS TRUE
      ORDER BY pub_date DESC
      LIMIT 100
    """

    case Repo.query(query) do
      {:ok, result = %Postgrex.Result{}} ->
        IO.puts("Found #{result.num_rows} read feed items...")
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

  @doc """
  Inserts all feed items of a given feed.

  Returns a tuple containing the number of entries and any returned result as second element.
  The second element will be `nil` if no result is returned.

  ## Examples

      iex> insert_all_feed_items(feed)
      {100, nil}

  """
  def insert_all_feed_items(feed) do
    feed_items = RssUtils.get_feed_items_from_rss_url(feed.url, feed.id)
    Repo.insert_all(FeedItem, feed_items, on_conflict: :nothing)
  end

  @doc """
  Gets a feed item data transfer object given the feed item and the user.

  ## Examples

      iex> get_feed_item_dto(item, user)
      %FeedItemDto{}

  """
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

  @doc """
  Inserts all new feed items for all feeds.

  Returns a the result of the async stream used to perform the item storage work.

  ## Examples

      iex> store_new_feed_items()
      [ok: 5, ok: 0, ok: 2]

  """
  def store_new_feed_items do
    feeds = get_feeds_with_subs()
    IO.puts("Found #{Enum.count(feeds)} feeds with subscriptions...")

    response =
      feeds
      |> Task.async_stream(
        fn feed ->
          items = RssUtils.get_feed_items_from_rss_url(feed.url, feed.id)
          {num_items_added, nil} = Repo.insert_all(FeedItem, items, on_conflict: :nothing)

          for user_id <- get_subscriber_ids(feed.id) do
            AccountContent.create_feed_item_statuses(user_id, feed)
          end

          num_items_added
        end,
        max_concurrency: 4,
        timeout: 10_000
      )
      |> Enum.to_list()

    response
  end

  defp get_subscriber_ids(feed_id) do
    query = """
      SELECT
        user_id
      FROM
        subscriptions
      WHERE
        feed_id = #{feed_id}
    """

    case Repo.query(query) do
      {:ok, result = %Postgrex.Result{}} ->
        IO.puts("Found #{result.num_rows} users subscribed to feed #{feed_id}...")

        result.rows
        |> Enum.map(fn [user_id] -> user_id end)

      _error ->
        []
    end
  end

  defp get_feeds_with_subs do
    AccountContent.list_subscriptions()
    |> Enum.filter(fn sub -> sub.is_subscribed end)
    |> Enum.uniq_by(fn sub -> sub.feed_id end)
    |> Repo.preload(:feed)
    |> Enum.map(fn sub -> sub.feed end)
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
      status = %AccountContent.FeedItemStatus{} ->
        status

      %{} ->
        {:ok, %FeedItemStatus{} = status} =
          AccountContent.create_feed_item_status(item, user, %{is_read: false})

        status
    end
  end
end

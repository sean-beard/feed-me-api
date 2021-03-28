defmodule FeedMe.RssUtils do
  @moduledoc """
  This module is a utilty to process RSS feeds.
  """

  alias FeedMe.Content.FeedItem
  alias FeedMe.YouTubeUtils
  alias HTTPoison.Response

  @doc """
  Gets an RSS URL.

  ## Examples

      iex> get_rss_url("https://my.rss.feed.com/feed.xml")
      "https://my.rss.feed.com/feed.xml"

      iex> get_rss_url("https://www.youtube.com/channel/UCkQX1tChV7Z7l1LFF4L9j_g")
      "https://www.youtube.com/feeds/videos.xml?channel_id=UCkQX1tChV7Z7l1LFF4L9j_g"

      iex> get_rss_url("https://www.youtube.com/c/StrangeLoopConf")
      "https://www.youtube.com/feeds/videos.xml?channel_id=UC_QIfHvN9auy2CoOdSfMWDw"
  """
  def get_rss_url(url_input) do
    if YouTubeUtils.is_youtube_url(url_input) &&
         YouTubeUtils.is_youtube_rss_url(url_input) == false do
      if YouTubeUtils.is_youtube_channel_url(url_input) do
        YouTubeUtils.get_rss_url_from_youtube_channel_url(url_input)
      else
        YouTubeUtils.get_rss_url_from_youtube_url(url_input)
      end
    else
      url_input
    end
  end

  @doc """
  Gets the feed for a given RSS URL.

  Returns `nil` if a feed can't be returned.

  ## Examples

      iex> get_feed_from_rss_url("https://my.rss.feed.com/feed.xml")
      %Feed{}

      iex> get_feed_from_rss_url("https://google.com")
      nil
  """
  def get_feed_from_rss_url(url_input) do
    url = get_rss_url(url_input)

    try do
      fetch_feed_from_rss_url(url)
    rescue
      _any_error -> nil
    catch
      _any_value -> nil
    end
  end

  @doc """
  Gets feed items for a given RSS URL.

  ## Examples

      iex> get_feed_items_from_rss_url("https://my.rss.feed.com/feed.xml")
      [%FeedItem{}, ...]
  """
  def get_feed_items_from_rss_url(url, feed_id) do
    get_rss_items_from_rss_url(url)
    |> convert_rss_items_to_db_items(feed_id)
  end

  defp fetch_feed_from_rss_url(url) do
    %Response{body: body} = HTTPoison.get!(url)

    case XmlToMap.naive_map(body) do
      %{
        "rss" => %{
          "#content" => %{
            "channel" => %{
              "description" => description,
              "title" => name
            }
          }
        }
      } ->
        %{
          name: name,
          url: url,
          description: description
        }

      %{
        "feed" => %{
          "title" => name,
          "author" => %{
            "uri" => description
          }
        }
      } ->
        %{
          name: name,
          url: url,
          description: description
        }

      _ ->
        nil
    end
  end

  defp get_rss_items_from_rss_url(url) do
    %Response{body: body} = HTTPoison.get!(url)

    case XmlToMap.naive_map(body) do
      %{
        "rss" => %{
          "#content" => %{
            "channel" => %{
              "item" => items
            }
          }
        }
      } ->
        items

      %{
        "feed" => %{
          "entry" => items
        }
      } ->
        items

      _ ->
        []
    end
  end

  defp convert_rss_items_to_db_items(items, feed_id) do
    case items do
      single_item = %{} ->
        [convert_rss_item_to_db_item(single_item, feed_id)]

      _array ->
        Enum.map(items, fn item -> convert_rss_item_to_db_item(item, feed_id) end)
    end
  end

  defp convert_rss_item_to_db_item(item, feed_id) do
    case item do
      %{
        "title" => title,
        "description" => description,
        "link" => url,
        "pubDate" => pub_date,
        "enclosure" => %{
          "-type" => media_type,
          "-url" => media_url
        }
      } ->
        %FeedItem{
          title: title,
          description: :erlang.term_to_binary(description, [:compressed]),
          url: url,
          pub_date: pub_date,
          feed_id: feed_id,
          media_type: media_type,
          media_url: media_url
        }

      %{
        "title" => title,
        "description" => description,
        "pubDate" => pub_date,
        "enclosure" => %{
          "-type" => media_type,
          "-url" => media_url
        }
      } ->
        %FeedItem{
          title: title,
          description: :erlang.term_to_binary(description, [:compressed]),
          url: media_url,
          pub_date: pub_date,
          feed_id: feed_id,
          media_type: media_type,
          media_url: media_url
        }

      %{
        "title" => title,
        "description" => description,
        "link" => url,
        "pubDate" => pub_date
      } ->
        %FeedItem{
          title: title,
          description: :erlang.term_to_binary(description, [:compressed]),
          url: url,
          pub_date: pub_date,
          feed_id: feed_id
        }

      %{
        "title" => title,
        "published" => pub_date,
        "link" => %{
          "#content" => description,
          "-href" => url
        }
      } ->
        %FeedItem{
          title: title,
          description: :erlang.term_to_binary(description, [:compressed]),
          url: url,
          pub_date: pub_date,
          feed_id: feed_id
        }
    end
  end
end

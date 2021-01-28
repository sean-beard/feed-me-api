defmodule FeedMe.RssUtils do
  @moduledoc """
  This module is a utilty to process RSS feeds.
  """

  alias FeedMe.YouTubeUtils
  alias HTTPoison.Response

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

  def get_feed_from_rss_url(url_input) do
    url = get_rss_url(url_input)

    try do
      fetch_feed_from_rss_url(url)
    rescue
      _any_error -> nil
    end
  end

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
      [_array = %{}] ->
        Enum.map(items, fn item -> convert_rss_item_to_db_item(item, feed_id) end)

      single_item = %{} ->
        [convert_rss_item_to_db_item(single_item, feed_id)]
    end
  end

  defp convert_rss_item_to_db_item(item, feed_id) do
    case item do
      %{
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

      %{
        "title" => title,
        "published" => pub_date,
        "link" => %{
          "#content" => description,
          "-href" => url
        }
      } ->
        %{
          title: title,
          description: :erlang.term_to_binary(description, [:compressed]),
          url: url,
          pub_date: pub_date,
          feed_id: feed_id
        }
    end
  end
end

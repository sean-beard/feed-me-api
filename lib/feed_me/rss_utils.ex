defmodule FeedMe.RssUtils do
  @moduledoc """
  This module is a utilty to process RSS feeds.
  """

  alias FeedMe.YouTubeUtils
  alias HTTPoison.Response

  def get_feed_from_rss_url(url_input) do
    url =
      if YouTubeUtils.is_youtube_channel_url(url_input) do
        YouTubeUtils.get_rss_url_from_youtube_url(url_input)
      else
        url_input
      end

    %Response{body: body} = HTTPoison.get!(url)

    case XmlToMap.naive_map(body) do
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
    end
  end

  def get_feed_items_from_rss_url(url) do
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
    end
  end

  def convert_rss_items_to_db_items(items, feed_id) do
    Enum.map(items, fn item -> convert_rss_item_to_db_item(item, feed_id) end)
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

defmodule FeedMe.YouTubeUtils do
  @moduledoc """
  This module is a utilty to handle YouTube-specific logic.
  """

  alias HTTPoison.Response

  def is_youtube_url(url) do
    String.contains?(url, "youtube.com") || String.contains?(url, "youtu.be")
  end

  def is_youtube_rss_url(url) do
    String.contains?(url, "youtube.com/feeds")
  end

  def is_youtube_channel_url(url) do
    String.contains?(url, "youtube.com/channel/")
  end

  def get_rss_url_from_youtube_channel_url(url) do
    channel_id = get_youtube_channel_id(url)
    "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
  end

  def get_rss_url_from_youtube_url(url) do
    channel_id = scrape_youtube_channel_id(url)
    "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
  end

  defp scrape_youtube_channel_id(url) do
    %Response{body: body} = HTTPoison.get!(url)
    String.split(body, "\"externalId\":") |> Enum.at(-1) |> String.split("\"") |> Enum.at(1)
  end

  defp get_youtube_channel_id(url) do
    channel_id = String.split(url, "youtube.com/channel/") |> Enum.at(-1)

    if String.contains?(channel_id, "?") do
      String.split(channel_id, "?") |> Enum.at(0)
    else
      channel_id
    end
  end
end

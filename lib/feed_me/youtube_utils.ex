defmodule FeedMe.YouTubeUtils do
  @moduledoc """
  This module is a utilty to handle YouTube-specific logic.
  """

  alias HTTPoison.Response

  @doc """
  Returns a boolean designating whether or not a given URL is a YouTube URL.

  ## Examples

      iex> is_youtube_url("https://my.rss.feed.com/feed.xml")
      false

      iex> is_youtube_url("https://www.youtube.com/c/StrangeLoopConf")
      true
  """
  def is_youtube_url(url) do
    String.contains?(url, "youtube.com") || String.contains?(url, "youtu.be")
  end

  @doc """
  Returns a boolean designating whether or not a given URL is a YouTube RSS URL.

  ## Examples

      iex> is_youtube_rss_url("https://www.youtube.com/c/StrangeLoopConf")
      false

      iex> is_youtube_rss_url("https://www.youtube.com/feeds/videos.xml?channel_id=123abc")
      true
  """
  def is_youtube_rss_url(url) do
    String.contains?(url, "youtube.com/feeds")
  end

  @doc """
  Returns a boolean designating whether or not a given URL is a YouTube channel URL.

  ## Examples

      iex> is_youtube_channel_url("https://www.youtube.com/c/StrangeLoopConf")
      false

      iex> is_youtube_channel_url("https://www.youtube.com/channel/UCkQX1tChV7Z7l1LFF4L9j_g")
      true
  """
  def is_youtube_channel_url(url) do
    String.contains?(url, "youtube.com/channel/")
  end

  @doc """
  Gets a YouTube RSS URL from a given YouTube channel URL.

  ## Examples

      iex> get_rss_url_from_youtube_channel_url("https://www.youtube.com/channel/UCkQX1tChV7Z7l1LFF4L9j_g")
      "https://www.youtube.com/feeds/videos.xml?channel_id=UCkQX1tChV7Z7l1LFF4L9j_g"
  """
  def get_rss_url_from_youtube_channel_url(url) do
    channel_id = get_youtube_channel_id(url)
    "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
  end

  @doc """
  Gets a YouTube RSS URL from a given YouTube URL.

  ## Examples

      iex> get_rss_url_from_youtube_url("https://www.youtube.com/c/StrangeLoopConf")
      "https://www.youtube.com/feeds/videos.xml?channel_id=UC_QIfHvN9auy2CoOdSfMWDw"
  """
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

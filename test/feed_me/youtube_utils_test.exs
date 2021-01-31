defmodule FeedMe.YouTubeUtilsTest do
  use FeedMe.DataCase

  alias FeedMe.YouTubeUtils

  describe "youtube utils" do
    test "is_youtube_url/1 with invalid youtube url returns false" do
      assert YouTubeUtils.is_youtube_url("https://google.com") == false
    end

    test "is_youtube_url/1 with valid youtube url returns true" do
      valid_yt_urls = [
        "https://youtube.com/channel/1234",
        "https://youtube.com/c/test",
        "https://youtube.com/u/test",
        "https://youtu.be/1234",
        "youtube.com",
        "youtu.be"
      ]

      Enum.each(valid_yt_urls, fn url ->
        assert YouTubeUtils.is_youtube_url(url) == true
      end)
    end

    test "is_youtube_rss_url/1 with invalid youtube rss url returns false" do
      url = "https://google.com"

      assert YouTubeUtils.is_youtube_rss_url(url) == false
    end

    test "is_youtube_rss_url/1 with valid youtube rss url returns true" do
      url = "youtube.com/feeds/1234"

      assert YouTubeUtils.is_youtube_rss_url(url) == true
    end

    test "get_rss_url_from_youtube_channel_url/1 with returns correct rss url" do
      channel_id = "1234"
      url = "youtube.com/channel/#{channel_id}"

      assert YouTubeUtils.get_rss_url_from_youtube_channel_url(url) ==
               "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
    end

    test "get_rss_url_from_youtube_url/1 with returns correct rss url" do
      url = "https://www.youtube.com/c/programmedlive"

      assert YouTubeUtils.get_rss_url_from_youtube_url(url) ==
               "https://www.youtube.com/feeds/videos.xml?channel_id=UCDzfXZxesMP-LUICN-RWcbQ"
    end
  end
end

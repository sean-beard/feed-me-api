defmodule FeedMe.RssUtilsTest do
  use FeedMe.DataCase

  alias FeedMe.RssUtils

  describe "rss utils" do
    test "get_rss_url/1 returns the correct rss url" do
      url = "https://cprss.s3.amazonaws.com/frontendfoc.us.xml"
      assert RssUtils.get_rss_url(url) == url
    end

    test "get_rss_url/1 with youtube channel url returns the correct rss url" do
      channel_id = "1234"
      url = "youtube.com/channel/#{channel_id}"

      assert RssUtils.get_rss_url(url) ==
               "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
    end

    test "get_rss_url/1 with youtube url returns the correct rss url" do
      url = "https://www.youtube.com/c/programmedlive"

      assert RssUtils.get_rss_url(url) ==
               "https://www.youtube.com/feeds/videos.xml?channel_id=UCDzfXZxesMP-LUICN-RWcbQ"
    end

    test "get_rss_url/1 with youtube rss url returns the correct rss url" do
      url = "youtube.com/feeds/1234"

      assert RssUtils.get_rss_url(url) == "youtube.com/feeds/1234"
    end

    test "get_feed_from_rss_url/1 with supported rss url returns the correct feed data" do
      url = "https://cprss.s3.amazonaws.com/frontendfoc.us.xml"

      assert RssUtils.get_feed_from_rss_url(url) ==
               %{
                 description:
                   "A once–weekly roundup of the best front-end news, articles and tutorials. HTML, CSS, WebGL, Canvas, browser tech, and more.",
                 name: "Frontend Focus",
                 url: "https://cprss.s3.amazonaws.com/frontendfoc.us.xml"
               }
    end

    test "get_feed_from_rss_url/1 with unsupported rss url returns nil" do
      url = "https://google.com"

      assert RssUtils.get_feed_from_rss_url(url) == nil
    end

    test "get_feed_items_from_rss_url/2 with supported rss url returns items" do
      feed_id = 1
      url = "https://cprss.s3.amazonaws.com/frontendfoc.us.xml"
      items = RssUtils.get_feed_items_from_rss_url(url, feed_id)

      Enum.each(items, fn item ->
        assert item.feed_id == feed_id
        assert Map.has_key?(item, :description) == true
        assert Map.has_key?(item, :pub_date) == true
        assert Map.has_key?(item, :title) == true
        assert Map.has_key?(item, :url) == true
      end)

      assert Enum.count(items) == 4
    end

    test "get_feed_items_from_rss_url/2 with unsupported rss url returns empty array" do
      feed_id = 1
      url = "https://google.com"

      assert RssUtils.get_feed_items_from_rss_url(url, feed_id) == []
    end
  end
end

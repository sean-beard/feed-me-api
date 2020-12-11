defmodule FeedMe.ContentTest do
  use FeedMe.DataCase
  use FeedMe.Fixtures, [:feed, :user, :feed_item, :feed_item_status]

  alias FeedMe.Content

  describe "feeds" do
    alias FeedMe.Content.Feed

    @valid_attrs %{description: "some description", name: "some name", url: "some url"}
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      url: "some updated url"
    }
    @invalid_attrs %{description: nil, name: nil, url: nil}

    # TODO: fix this
    # test "list_feeds/2 returns all feeds for list of IDs" do
    #   user = user_fixture()
    #   feed = feed_fixture()
    #   feed_item = feed_item_fixture(%{feed_id: feed.id})

    #   feed_item_status = feed_item_status_fixture(user, feed_item)

    #   feed_item_with_status =
    #     feed_item
    #     |> Map.put(:feed_item_statuses, [feed_item_status])

    #   pre_loaded_feed =
    #     feed
    #     |> Map.put(:feed_items, [feed_item_with_status])
    #     |> Repo.preload(feed_items: :feed_item_statuses)

    #   assert Content.list_feeds([feed.id], user.id) == [pre_loaded_feed]
    # end

    test "get_feed!/1 returns the feed with given id" do
      feed = feed_fixture()
      assert Content.get_feed!(feed.id) == feed
    end

    test "create_feed/1 with valid data creates a feed" do
      assert {:ok, %Feed{} = feed} = Content.create_feed(@valid_attrs)
      assert feed.description == "some description"
      assert feed.name == "some name"
      assert feed.url == "some url"
    end

    test "create_feed/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_feed(@invalid_attrs)
    end

    test "update_feed/2 with valid data updates the feed" do
      feed = feed_fixture()
      assert {:ok, %Feed{} = feed} = Content.update_feed(feed, @update_attrs)
      assert feed.description == "some updated description"
      assert feed.name == "some updated name"
      assert feed.url == "some updated url"
    end

    test "update_feed/2 with invalid data returns error changeset" do
      feed = feed_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_feed(feed, @invalid_attrs)
      assert feed == Content.get_feed!(feed.id)
    end

    test "delete_feed/1 deletes the feed" do
      feed = feed_fixture()
      assert {:ok, %Feed{}} = Content.delete_feed(feed)
      assert_raise Ecto.NoResultsError, fn -> Content.get_feed!(feed.id) end
    end

    test "change_feed/1 returns a feed changeset" do
      feed = feed_fixture()
      assert %Ecto.Changeset{} = Content.change_feed(feed)
    end
  end
end

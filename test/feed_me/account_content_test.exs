defmodule FeedMe.AccountContentTest do
  use FeedMe.DataCase
  use FeedMe.Fixtures, [:user, :feed, :feed_item, :feed_item_status]

  alias FeedMe.AccountContent

  describe "subscriptions" do
    alias FeedMe.AccountContent.Subscription

    @update_attrs %{is_subscribed: false}
    @invalid_attrs %{is_subscribed: nil}

    def subscription_fixture(user \\ user_fixture()) do
      feed = feed_fixture()

      {:ok, subscription} = AccountContent.create_subscription(user, feed)

      subscription
    end

    test "list_subscriptions/1 returns all subscriptions" do
      user = user_fixture()
      subscription = subscription_fixture(user)

      assert AccountContent.list_subscriptions(user.id) |> Repo.preload(:user) == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()

      assert AccountContent.get_subscription!(subscription.id) |> Repo.preload(:user) ==
               subscription
    end

    test "create_subscription/2 with valid data creates a subscription" do
      user = user_fixture()
      feed = feed_fixture()

      assert {:ok, %Subscription{} = subscription} =
               AccountContent.create_subscription(user, feed)

      assert subscription.is_subscribed == true
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()

      assert {:ok, %Subscription{} = subscription} =
               AccountContent.update_subscription(subscription, @update_attrs)

      assert subscription.is_subscribed == false
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AccountContent.update_subscription(subscription, @invalid_attrs)

      assert subscription ==
               AccountContent.get_subscription!(subscription.id) |> Repo.preload(:user)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = AccountContent.delete_subscription(subscription)

      assert_raise Ecto.NoResultsError, fn ->
        AccountContent.get_subscription!(subscription.id)
      end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = AccountContent.change_subscription(subscription)
    end
  end

  describe "feed_item_statuses" do
    alias FeedMe.AccountContent.FeedItemStatus

    @update_attrs %{is_read: false}
    @invalid_attrs %{is_read: nil}

    test "list_feed_item_statuses/0 returns all feed_item_statuses" do
      user = user_fixture()
      feed_item = feed_item_fixture()
      feed_item_status = feed_item_status_fixture(user, feed_item)
      assert AccountContent.list_feed_item_statuses() |> Repo.preload(:user) == [feed_item_status]
    end

    test "get_feed_item_status/1 returns the feed_item_status with given id" do
      user = user_fixture()
      feed_item = feed_item_fixture()
      feed_item_status = feed_item_status_fixture(user, feed_item)

      assert AccountContent.get_feed_item_status(feed_item_status.feed_item_id, user.id)
             |> Repo.preload(:user) ==
               [feed_item_status]
    end

    test "create_feed_item_status/3 with valid data creates a feed_item_status" do
      feed_item = feed_item_fixture()
      user = user_fixture()
      is_read = true

      assert {:ok, %FeedItemStatus{} = feed_item_status} =
               AccountContent.create_feed_item_status(feed_item, user, %{is_read: is_read})

      assert feed_item_status.is_read == true
    end

    test "create_feed_item_status/1 with invalid data returns error changeset" do
      feed_item = feed_item_fixture()
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AccountContent.create_feed_item_status(feed_item, user, @invalid_attrs)
    end

    test "update_feed_item_status/2 with valid data updates the feed_item_status" do
      user = user_fixture()
      feed_item = feed_item_fixture()
      feed_item_status = feed_item_status_fixture(user, feed_item)

      assert {:ok, %FeedItemStatus{} = feed_item_status} =
               AccountContent.update_feed_item_status(feed_item_status, @update_attrs)

      assert feed_item_status.is_read == false
    end

    test "update_feed_item_status/2 with invalid data returns error changeset" do
      user = user_fixture()
      feed_item = feed_item_fixture()
      feed_item_status = feed_item_status_fixture(user, feed_item)

      assert {:error, %Ecto.Changeset{}} =
               AccountContent.update_feed_item_status(feed_item_status, @invalid_attrs)

      assert [feed_item_status] ==
               AccountContent.get_feed_item_status(feed_item_status.feed_item_id, user.id)
               |> Repo.preload(:user)
    end

    test "delete_feed_item_status/1 deletes the feed_item_status" do
      user = user_fixture()
      feed_item = feed_item_fixture()
      feed_item_status = feed_item_status_fixture(user, feed_item)
      assert {:ok, %FeedItemStatus{}} = AccountContent.delete_feed_item_status(feed_item_status)

      assert AccountContent.get_feed_item_status(feed_item_status.feed_item_id, user.id) == []
    end

    test "change_feed_item_status/1 returns a feed_item_status changeset" do
      user = user_fixture()
      feed_item = feed_item_fixture()
      feed_item_status = feed_item_status_fixture(user, feed_item)
      assert %Ecto.Changeset{} = AccountContent.change_feed_item_status(feed_item_status)
    end
  end
end

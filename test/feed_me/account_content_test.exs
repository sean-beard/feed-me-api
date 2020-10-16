defmodule FeedMe.AccountContentTest do
  use FeedMe.DataCase

  alias FeedMe.AccountContent

  describe "subscriptions" do
    alias FeedMe.AccountContent.Subscription

    @valid_attrs %{is_subscribed: true}
    @update_attrs %{is_subscribed: false}
    @invalid_attrs %{is_subscribed: nil}

    def subscription_fixture(attrs \\ %{}) do
      {:ok, subscription} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AccountContent.create_subscription()

      subscription
    end

    test "list_subscriptions/0 returns all subscriptions" do
      subscription = subscription_fixture()
      assert AccountContent.list_subscriptions() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert AccountContent.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      assert {:ok, %Subscription{} = subscription} = AccountContent.create_subscription(@valid_attrs)
      assert subscription.is_subscribed == true
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccountContent.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{} = subscription} = AccountContent.update_subscription(subscription, @update_attrs)
      assert subscription.is_subscribed == false
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = AccountContent.update_subscription(subscription, @invalid_attrs)
      assert subscription == AccountContent.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = AccountContent.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> AccountContent.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = AccountContent.change_subscription(subscription)
    end
  end

  describe "feed_item_statuses" do
    alias FeedMe.AccountContent.FeedItemStatus

    @valid_attrs %{is_read: true}
    @update_attrs %{is_read: false}
    @invalid_attrs %{is_read: nil}

    def feed_item_status_fixture(attrs \\ %{}) do
      {:ok, feed_item_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AccountContent.create_feed_item_status()

      feed_item_status
    end

    test "list_feed_item_statuses/0 returns all feed_item_statuses" do
      feed_item_status = feed_item_status_fixture()
      assert AccountContent.list_feed_item_statuses() == [feed_item_status]
    end

    test "get_feed_item_status!/1 returns the feed_item_status with given id" do
      feed_item_status = feed_item_status_fixture()
      assert AccountContent.get_feed_item_status!(feed_item_status.id) == feed_item_status
    end

    test "create_feed_item_status/1 with valid data creates a feed_item_status" do
      assert {:ok, %FeedItemStatus{} = feed_item_status} = AccountContent.create_feed_item_status(@valid_attrs)
      assert feed_item_status.is_read == true
    end

    test "create_feed_item_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccountContent.create_feed_item_status(@invalid_attrs)
    end

    test "update_feed_item_status/2 with valid data updates the feed_item_status" do
      feed_item_status = feed_item_status_fixture()
      assert {:ok, %FeedItemStatus{} = feed_item_status} = AccountContent.update_feed_item_status(feed_item_status, @update_attrs)
      assert feed_item_status.is_read == false
    end

    test "update_feed_item_status/2 with invalid data returns error changeset" do
      feed_item_status = feed_item_status_fixture()
      assert {:error, %Ecto.Changeset{}} = AccountContent.update_feed_item_status(feed_item_status, @invalid_attrs)
      assert feed_item_status == AccountContent.get_feed_item_status!(feed_item_status.id)
    end

    test "delete_feed_item_status/1 deletes the feed_item_status" do
      feed_item_status = feed_item_status_fixture()
      assert {:ok, %FeedItemStatus{}} = AccountContent.delete_feed_item_status(feed_item_status)
      assert_raise Ecto.NoResultsError, fn -> AccountContent.get_feed_item_status!(feed_item_status.id) end
    end

    test "change_feed_item_status/1 returns a feed_item_status changeset" do
      feed_item_status = feed_item_status_fixture()
      assert %Ecto.Changeset{} = AccountContent.change_feed_item_status(feed_item_status)
    end
  end
end

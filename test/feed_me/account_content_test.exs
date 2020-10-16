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
end

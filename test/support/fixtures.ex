defmodule FeedMe.Fixtures do
  @moduledoc """
  A module for defining fixtures that can be used in tests.
  This module can be used with a list of fixtures to apply as parameter:
      use FeedMe.Fixtures, [:user, :feed]
  """

  def user do
    alias FeedMe.Account

    quote do
      @valid_attrs %{
        email: "test@test.com",
        name: "John",
        provider: "github",
        token: "abc123"
      }

      def user_fixture(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Account.create_user()

        user
      end
    end
  end

  def feed do
    alias FeedMe.Content

    quote do
      @valid_attrs %{
        name: "Mock Feed",
        description: "Test description",
        url: "https://mockfeed.com"
      }

      def feed_fixture(attrs \\ %{}) do
        {:ok, feed} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Content.create_feed()

        feed
      end
    end
  end

  def feed_item do
    alias FeedMe.Content

    quote do
      @valid_attrs %{
        title: "Mock Feed Item",
        description: "Mock feed item description",
        url: "https://mockfeeditem.com",
        pub_date: "Wed, 28 Oct 2020 00:00:00 +0000"
      }

      def feed_item_fixture(attrs \\ %{}) do
        {:ok, feed_item} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Content.create_feed_item()

        feed_item
      end
    end
  end

  def feed_item_status do
    alias FeedMe.AccountContent

    quote do
      def feed_item_status_fixture(user, feed_item) do
        feed_item = feed_item_fixture()
        is_read = true

        {:ok, feed_item_status} = AccountContent.create_feed_item_status(feed_item, user, is_read)

        feed_item_status
      end
    end
  end

  @doc """
  Apply the `fixtures`.
  """
  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end

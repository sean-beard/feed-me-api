defmodule FeedMe.Content.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field :description, :string
    field :name, :string
    field :url, :string
    has_many :feed_items, FeedMe.Content.FeedItem
    has_many :subscriptions, FeedMe.AccountContent.Subscription

    timestamps()
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:name, :description, :url])
    |> validate_required([:name, :description, :url])
  end
end

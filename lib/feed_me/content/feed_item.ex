defmodule FeedMe.Content.FeedItem do
  @moduledoc """
  This module describes a `FeedItem`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "feed_items" do
    field :description, :string
    field :pub_date, :date
    field :title, :string
    field :url, :string
    belongs_to :feed, FeedMe.Content.Feed
    has_many :feed_item_statuses, FeedMe.AccountContent.FeedItemStatus
  end

  @doc false
  def changeset(feed_item, attrs) do
    feed_item
    |> cast(attrs, [:title, :description, :url, :pub_date])
    |> validate_required([:title, :description, :url, :pub_date])
    |> foreign_key_constraint(:feed_id)
    |> unique_constraint([:url, :feed_id], name: :feed_items_index)
  end
end

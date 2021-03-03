defmodule FeedMe.Content.FeedItem do
  @moduledoc """
  This module describes a `FeedItem`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :description,
             :url,
             :pubDate,
             :isRead,
             :currentTime,
             :mediaType,
             :mediaUrl
           ]}

  schema "feed_items" do
    field :description, :string
    field :pub_date, :string
    field :title, :string
    field :url, :string
    field :media_type, :string
    field :media_url, :string
    belongs_to :feed, FeedMe.Content.Feed
    has_many :feed_item_statuses, FeedMe.AccountContent.FeedItemStatus
  end

  @doc false
  def changeset(feed_item, attrs) do
    feed_item
    |> cast(attrs, [:title, :description, :url, :pub_date, :media_type, :media_url])
    |> validate_required([:title, :description, :url])
    |> foreign_key_constraint(:feed_id)
    |> unique_constraint([:url, :feed_id], name: :feed_items_index)
  end
end

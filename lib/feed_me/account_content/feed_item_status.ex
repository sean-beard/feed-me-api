defmodule FeedMe.AccountContent.FeedItemStatus do
  @moduledoc """
  This module describes a `FeedItemStatus`. This keeps track of whether or not a feed item has been read.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "feed_item_statuses" do
    field :is_read, :boolean, default: false
    field :current_time_sec, :float
    belongs_to :feed_item, FeedMe.Content.FeedItem
    belongs_to :user, FeedMe.Account.User

    timestamps()
  end

  @doc false
  def changeset(feed_item_status, attrs) do
    feed_item_status
    |> cast(attrs, [:is_read, :current_time_sec])
    |> validate_required([:is_read])
  end
end

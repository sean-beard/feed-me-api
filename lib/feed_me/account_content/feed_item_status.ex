defmodule FeedMe.AccountContent.FeedItemStatus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feed_item_statuses" do
    field :is_read, :boolean, default: false
    belongs_to :feed_item, FeedMe.Content.FeedItem
    belongs_to :user, FeedMe.Account.User

    timestamps()
  end

  @doc false
  def changeset(feed_item_status, attrs) do
    feed_item_status
    |> cast(attrs, [:is_read])
    |> validate_required([:is_read])
  end
end

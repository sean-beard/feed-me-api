defmodule FeedMe.AccountContent.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :is_subscribed, :boolean, default: false
    belongs_to :feed, FeedMe.Content.Feed
    belongs_to :user, FeedMe.Account.User

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:is_subscribed])
    |> validate_required([:is_subscribed])
  end
end
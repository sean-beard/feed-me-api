defmodule FeedMe.AccountContent.Subscription do
  @moduledoc """
  This module describes a `Subscription`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :isSubscribed, :feedName]}

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
    |> unique_constraint([:user_id, :feed_id], name: :subscriptions_fk_index)
  end
end

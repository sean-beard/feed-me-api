defmodule FeedMe.AccountContent.NotificationSubscription do
  @moduledoc """
  This module describes a `NotificationSubscription`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_subscriptions" do
    field :endpoint, :string
    field :auth, :string
    field :p256dh, :string
    field :origin, :string
    field :expiration_time, :float
    belongs_to :user, FeedMe.Account.User

    timestamps()
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:endpoint, :auth, :p256dh, :origin, :expiration_time])
    |> validate_required([:endpoint, :auth, :p256dh, :origin])
  end
end

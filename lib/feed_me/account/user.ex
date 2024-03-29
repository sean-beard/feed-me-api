defmodule FeedMe.Account.User do
  @moduledoc """
  This module describes a `User`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :provider, :string
    field :token, :string
    field :notification_enabled, :boolean
    has_many :subscriptions, FeedMe.AccountContent.Subscription
    has_many :feed_item_statuses, FeedMe.AccountContent.FeedItemStatus

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :provider, :token, :notification_enabled])
    |> validate_required([:name, :email, :provider, :token])
  end
end

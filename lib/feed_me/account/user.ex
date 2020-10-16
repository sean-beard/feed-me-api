defmodule FeedMe.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :provider, :string
    field :token, :string
    has_many :subscriptions, FeedMe.AccountContent.Subscription
    has_many :feed_item_statuses, FeedMe.AccountContent.FeedItemStatus

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :provider, :token])
    |> validate_required([:name, :email, :provider, :token])
  end
end

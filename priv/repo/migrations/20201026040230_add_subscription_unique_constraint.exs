defmodule FeedMe.Repo.Migrations.AddSubscriptionUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:subscriptions, [:user_id, :feed_id],
             name: :subscriptions_fk_index,
             message: "Subscription record already exists."
           )
  end
end

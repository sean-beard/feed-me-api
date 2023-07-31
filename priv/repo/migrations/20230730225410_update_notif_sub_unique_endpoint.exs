defmodule FeedMe.Repo.Migrations.UpdateNotifSubUniqueEndpoint do
  use Ecto.Migration

  def change do
    create unique_index(:notification_subscriptions, [:endpoint],
             name: :notification_subscriptions_index,
             message: "Subscription record already exists."
           )
  end
end

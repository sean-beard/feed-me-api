defmodule FeedMe.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :is_subscribed, :boolean, default: false, null: false
      add :feed_id, references(:feeds)
      add :user_id, references(:users)

      timestamps()
    end

  end
end

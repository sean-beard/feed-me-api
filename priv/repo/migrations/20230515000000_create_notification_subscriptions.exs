defmodule FeedMe.Repo.Migrations.CreateNotificationSubscriptions do
  use Ecto.Migration

  def change do
    create table(:notification_subscriptions) do
      add :endpoint, :string, null: false
      add :auth, :string, null: false
      add :p256dh, :string, null: false
      add :origin, :string, null: false
      add :expiration_time, :float
      add :user_id, references(:users)

      timestamps()
    end
  end
end

defmodule FeedMe.Repo.Migrations.AddNotificationEnabledField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :notification_enabled, :boolean
    end
  end
end

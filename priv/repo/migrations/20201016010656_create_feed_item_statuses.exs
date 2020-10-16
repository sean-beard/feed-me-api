defmodule FeedMe.Repo.Migrations.CreateFeedItemStatuses do
  use Ecto.Migration

  def change do
    create table(:feed_item_statuses) do
      add :is_read, :boolean, default: false, null: false
      add :feed_item_id, references(:feed_items)
      add :user_id, references(:users)

      timestamps()
    end

  end
end

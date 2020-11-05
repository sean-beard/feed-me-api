defmodule FeedMe.Repo.Migrations.RemoveFeedItemTimestamps do
  use Ecto.Migration

  def change do
    alter table(:feed_items) do
      remove :inserted_at
      remove :updated_at
    end
  end
end

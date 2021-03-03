defmodule FeedMe.Repo.Migrations.AddItemStatusFieldCurrentTime do
  use Ecto.Migration

  def change do
    alter table(:feed_item_statuses) do
      add :current_time_sec, :float
    end
  end
end

defmodule FeedMe.Repo.Migrations.AddFeedItemMediaFields do
  use Ecto.Migration

  def change do
    alter table(:feed_items) do
      add :media_type, :string
      add :media_url, :string
    end
  end
end

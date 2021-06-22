defmodule FeedMe.Repo.Migrations.UpdateFeedItemMediaUrlType do
  use Ecto.Migration

  def change do
    alter table(:feed_items) do
      modify :media_url, :text
    end
  end
end

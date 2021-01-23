defmodule FeedMe.Repo.Migrations.CreateFeedItemStatusCompositePk do
  use Ecto.Migration

  def change do
    drop(constraint("feed_item_statuses", "feed_item_statuses_pkey"))

    alter table(:feed_item_statuses) do
      modify(:user_id, :integer, primary_key: true)
      modify(:feed_item_id, :integer, primary_key: true)
    end
  end
end

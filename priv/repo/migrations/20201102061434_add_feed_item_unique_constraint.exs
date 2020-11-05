defmodule FeedMe.Repo.Migrations.AddFeedItemUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:feed_items, [:url, :feed_id],
             name: :feed_items_index,
             message: "Feed item record already exists."
           )
  end
end

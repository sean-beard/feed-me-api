defmodule FeedMe.Repo.Migrations.AddFeedUrlUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:feeds, [:url],
             name: :feeds_url_index,
             message: "Feed record already exists."
           )
  end
end

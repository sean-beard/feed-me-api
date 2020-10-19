defmodule FeedMe.Repo.Migrations.CreateFeedItems do
  use Ecto.Migration

  def change do
    create table(:feed_items) do
      add :title, :string
      add :description, :string
      add :url, :string
      add :pub_date, :date
      add :feed_id, references(:feeds)

      timestamps()
    end
  end
end

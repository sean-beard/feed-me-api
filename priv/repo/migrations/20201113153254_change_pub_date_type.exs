defmodule FeedMe.Repo.Migrations.ChangePubDateType do
  use Ecto.Migration

  def change do
    alter table(:feed_items) do
      modify :pub_date, :string
    end
  end
end

defmodule FeedMe.Repo.Migrations.UpdateFeedItemDescType do
  use Ecto.Migration

  def up do
    execute """
    alter table feed_items alter column description type bytea using (description::bytea)
    """
  end

  def down do
    execute """
    alter table feed_items alter column description type character varying(255)
    """
  end
end

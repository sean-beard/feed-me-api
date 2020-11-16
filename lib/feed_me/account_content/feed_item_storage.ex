defmodule FeedMe.AccountContent.FeedItemStorage do
  @moduledoc """
  This module stores new feed items from feeds with subscriptions.
  """

  alias FeedMe.AccountContent
  alias FeedMe.Content

  def store do
    log_current_time_utc()
    IO.puts("Starting job to store new feed items...")
    feeds_with_subs = get_feeds_with_subs()

    IO.puts("Total feed count: #{Enum.count(feeds_with_subs)}")

    IO.puts("Inserting new feed items...")
    feeds_with_subs |> Enum.each(&Content.insert_all_feed_items/1)

    IO.puts("Done storing new feed items...")
    log_current_time_utc()
  end

  defp get_feeds_with_subs do
    AccountContent.list_subscriptions()
    |> FeedMe.Repo.preload(:feed)
    |> Enum.uniq_by(fn sub -> sub.feed.id end)
    |> Enum.map(fn sub -> sub.feed end)
  end

  defp log_current_time_utc do
    current_time = DateTime.utc_now() |> DateTime.to_string()
    IO.puts(current_time)
  end
end

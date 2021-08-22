defmodule FeedMe.AccountContent.FeedItemStorage do
  @moduledoc """
  This module stores new feed items from feeds with subscriptions.
  """

  alias FeedMe.Content

  def store do
    log_current_time_utc()
    IO.puts("Starting job to store new feed items...")
    IO.puts("Inserting new feed items...")

    Content.store_new_feed_items()

    IO.puts("Done storing new feed items...")
    log_current_time_utc()
  end

  defp log_current_time_utc do
    current_time = DateTime.utc_now() |> DateTime.to_string()
    IO.puts(current_time)
  end
end

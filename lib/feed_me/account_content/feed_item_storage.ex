defmodule FeedMe.AccountContent.FeedItemStorage do
  @moduledoc """
  This module stores new feed items from feeds with subscriptions.
  """

  alias FeedMe.AccountContent.Notification
  alias FeedMe.Content

  def store do
    log_current_time_utc()
    IO.puts("Starting job to store new feed items...")

    start_unread_item_counts = Notification.get_unread_item_count_by_user()

    IO.puts("Inserting new feed items...")
    Content.store_new_feed_items()
    IO.puts("Done storing new feed items...")

    end_unread_item_counts = Notification.get_unread_item_count_by_user()

    Notification.get_new_unread_item_count_by_user(
      start_unread_item_counts,
      end_unread_item_counts
    )
    |> Enum.map(fn %{user_id: user_id, num_unread_items: num_unread_items} ->
      Notification.send_notifications(%{user_id: user_id, num_unread_items: num_unread_items})
    end)

    log_current_time_utc()
  end

  defp log_current_time_utc do
    current_time = DateTime.utc_now() |> DateTime.to_string()
    IO.puts(current_time)
  end
end

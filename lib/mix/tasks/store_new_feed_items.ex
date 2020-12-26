defmodule Mix.Tasks.StoreNewFeedItems do
  @moduledoc """
  This module defined a mix task to store new feed items from feeds with subscriptions.
  """
  use Mix.Task

  alias FeedMe.AccountContent.FeedItemStorage

  @shortdoc "Simply calls the FeedItemStorage.store/0 function."
  def run(_) do
    # This will start our application
    Mix.Task.run("app.start")

    FeedItemStorage.store()
  end
end

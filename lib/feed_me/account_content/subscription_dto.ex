defmodule FeedMe.AccountContent.SubscriptionDto do
  @moduledoc """
  This module describes a `SubscriptionDto` struct.
  """

  @derive {Jason.Encoder, only: [:id, :feedName]}
  defstruct id: nil, feedName: ""
end

defmodule FeedMe.AccountContent.SubscriptionDto do
  @moduledoc """
  This module describes a `SubscriptionDto` struct.
  """

  @derive {Jason.Encoder,
           only: [
             :id,
             :feedName,
             :isSubscribed
           ]}
  defstruct id: nil,
            feedName: "",
            isSubscribed: false
end

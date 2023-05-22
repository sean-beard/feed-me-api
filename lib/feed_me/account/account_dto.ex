defmodule FeedMe.Account.AccountDto do
  @moduledoc """
  This module describes an `AccountDto` struct.
  """

  @derive {Jason.Encoder, only: [:notificationEnabled]}
  defstruct notificationEnabled: nil
end

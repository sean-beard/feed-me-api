defmodule FeedMe.Content.FeedItemDto do
  @moduledoc """
  This module describes a `FeedItemDto` struct.
  """

  @derive {Jason.Encoder,
           only: [
             :id,
             :feedName,
             :title,
             :description,
             :url,
             :pubDate,
             :isRead,
             :currentTime,
             :mediaType,
             :mediaUrl
           ]}
  defstruct id: nil,
            feedName: "",
            title: "",
            description: "",
            url: "",
            isRead: false,
            currentTime: nil,
            mediaType: "",
            mediaUrl: "",
            pubDate: ""
end

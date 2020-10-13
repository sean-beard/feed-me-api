defmodule FeedMe.Repo do
  use Ecto.Repo,
    otp_app: :feed_me,
    adapter: Ecto.Adapters.Postgres
end

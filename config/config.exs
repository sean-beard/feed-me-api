# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :feed_me,
  ecto_repos: [FeedMe.Repo]

# Configures the endpoint
config :feed_me, FeedMeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mNKEkXKXjB+nrh8+Ozkda9hjA9Uij9Z7dNWVYCouHAjvSFADZyS00INOXxVF5TO2",
  render_errors: [view: FeedMeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FeedMe.PubSub,
  live_view: [signing_salt: "DVvBduPi"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email", send_redirect_uri: false]}
  ]

config :feed_me, FeedMe.Scheduler,
  jobs: [
    # Every 2 hours
    {"0 */2 * * *", {FeedMe.AccountContent.FeedItemStorage, :store, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

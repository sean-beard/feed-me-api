# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

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
    github: {Ueberauth.Strategy.Github, [default_scope: "user"]}
  ]

defmodule DotEnv do
  def get_env(key) do
    {_env_key, val} =
      get_env_vars()
      |> Enum.find(fn {env_key, _env_val} -> key == env_key end)

    val
  end

  defp get_env_vars() do
    {_status, content} = File.read("#{File.cwd!()}/.env")

    String.split(content, "\n")
    |> Enum.filter(fn x -> String.contains?(x, "=") end)
    |> Enum.map(fn x -> get_key_val_pairs(x) end)
  end

  defp get_key_val_pairs(string) do
    {index_of_equals, _num_chars} = :binary.match(string, "=")
    key = String.slice(string, 0, index_of_equals)
    value = String.slice(string, index_of_equals + 1, String.length(string))
    {key, value}
  end
end

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: DotEnv.get_env("GITHUB_CLIENT_ID"),
  client_secret: DotEnv.get_env("GITHUB_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

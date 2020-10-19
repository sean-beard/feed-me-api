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
    case File.read("#{File.cwd!()}/.env") do
      {:ok, env_config} ->
        get_config_value_from_key(key, env_config)

      {:error, _reason} ->
        ""
    end
  end

  defp get_config_value_from_key(key, env_config) do
    config_line =
      String.split(env_config, "\n")
      |> Enum.filter(fn x -> String.contains?(x, "=") end)
      |> Enum.find("", fn x -> key == String.slice(x, 0, get_index_of(x, "=")) end)

    if String.contains?(config_line, "=") do
      String.slice(config_line, get_index_of(config_line, "=") + 1, String.length(config_line))
    else
      ""
    end
  end

  defp get_index_of(string_content, string_to_match) do
    {index_of_equals, _num_chars} = :binary.match(string_content, string_to_match)
    index_of_equals
  end
end

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: DotEnv.get_env("GITHUB_CLIENT_ID"),
  client_secret: DotEnv.get_env("GITHUB_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

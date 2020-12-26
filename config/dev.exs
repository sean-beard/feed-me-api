use Mix.Config

# Configure your database
config :feed_me, FeedMe.Repo,
  username: "postgres",
  password: "postgres",
  database: "feed_me_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :feed_me, FeedMeWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :feed_me, FeedMeWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/feed_me_web/(live|views)/.*(ex)$",
      ~r"lib/feed_me_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :feed_me, FeedMe.Scheduler,
  jobs: [
    # At midnight every night
    {"@daily", {FeedMe.AccountContent.FeedItemStorage, :store, []}}
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

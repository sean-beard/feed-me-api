defmodule FeedMe.MixProject do
  use Mix.Project

  def project do
    [
      app: :feed_me,
      version: "0.1.0",
      elixir: "~> 1.14.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      # ex_doc config
      name: "FeedMe",
      source_url: "https://github.com/sean-beard/feed-me",
      homepage_url: "https://github.com/sean-beard/feed-me/blob/master/README.md"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FeedMe.Application, []},
      extra_applications: [:logger, :runtime_tools, :ueberauth_github]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cors_plug, "~> 1.5"},
      {:ecto_sql, "~> 3.4"},
      {:elixir_xml_to_map, "~> 2.0"},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix, "~> 1.6.8"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:quantum, "~> 3.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:ueberauth, "~> 0.6.3"},
      {:ueberauth_github, "~> 0.7.0"},
      {:web_push_encryption, "~> 0.3"},

      # Development/Test
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end

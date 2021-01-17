# FeedMe API

RSS feed management application allowing users to get a personalized newsfeed that they create.

[FeedMe Staging app](https://feed-me-staging.netlify.app/)

[FeedMe Frontend](https://github.com/sean-beard/feed-me)

## Development

Make sure to have Elixir, Erlang and NodeJS installed on your machine. This application was developed with:

- Elixir v1.10.4
- Erlang v23.1
- NodeJS v12.18.2
- Postgres v12.2 (needs to be v9.5 or higher)

You can run `mix docs` to generate the documentation for this project.

### Getting started

Get the dependencies

```bash
$ mix deps.get
```

Set up the database

```bash
$ mix ecto.create
$ mix ecto.migrate
```

Define the environment variables

```bash
$ cp .env.sample .env
```

Start the Phoenix server

```bash
$ mix phx.server
```

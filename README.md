# FeedMe API

https://feedme.digital

RSS feed reader API allowing users to curate a truly personalized newsfeed.

Users authenticate via GitHub and can subscribe to RSS feeds. If a feed doesn't exist in the database (i.e. no other user has subscribed to the feed before) a new feed record will be stored.

Aditionally, available feed items will be stored. There is a job scheduled every two hours which will fetch and store new feed items.

## Endpoints

| Endpoint                |  Verb  |                                      Description |
| :---------------------- | :----: | -----------------------------------------------: |
| `/feed`                 |  GET   |                             Get the user's feed. |
| `/item/:id`             |  GET   |                           Get a feed item by ID. |
| `/item`                 |  PUT   |                            Upsert item statuses. |
| `/subscription`         |  GET   |               Get the user's feed subscriptions. |
| `/subscription`         |  POST  |                             Subscribe to a feed. |
| `/subscription`         | DELETE |                         Unsubscribe from a feed. |
| `/auth/logout`          |  GET   |                                 Logout the user. |
| `/auth/github`          |  GET   |                             Request GitHub auth. |
| `/auth/github/callback` |  GET   |        Login to the application via GitHub auth. |
| `/vapid-public-key`     |  GET   | Get the VAPID public key used for notifications. |
| `/notification`         |  POST  |            Store a new notifiction subscription. |
| `/notification`         |  PUT   |       Toggle notification preference for a user. |

## Development

You can run `mix docs` to generate the documentation for this project.

[FeedMe frontend repository](https://github.com/sean-beard/feed-me)

### Getting started

#### Docker compose

Make sure docker is running on your machine.

Start the API

```bash
$ docker-compose pull && docker-compose build && docker-compose up
```

API is now running on http://localhost:4000

Remove database data

```bash
$ docker-compose down --volumes
```

#### Local runtime dependencies

Make sure to have Elixir, Erlang and Postgres installed on your machine. This application was developed with:

- Elixir v1.14.4
- Erlang v25.3.2
- Postgres v13 (needs to be v9.5 or higher)

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

### Continuous Integration

This project uses Github actions for continuous integration. Source code must be verified, built and successfully tested before it can be merged.

[Credo](https://github.com/rrrene/credo) is used for static code analysis. [Mix](https://hexdocs.pm/mix/master/Mix.html) formatting capabilites are used for code formatting.

### Deployment

This project uses [Fly.io](https://fly.io/) for deployment. As of now, the API is manually deployed via [the Fly CLI](https://fly.io/docs/getting-started/installing-flyctl).

```bash
$ fly deploy --remote-only
```

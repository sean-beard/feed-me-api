FROM elixir:1.10

RUN apt-get update

# Install app dependencies
RUN apt-get install -y postgresql sudo inotify-tools

# App setup
RUN mix local.hex --force && mix local.rebar --force

ENV SHELL /bin/bash
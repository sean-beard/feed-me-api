FROM elixir:1.10

RUN apt-get update

# Install app dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs postgresql sudo inotify-tools

# App setup
RUN mix local.hex --force \
    && mix local.rebar --force

ENV SHELL /bin/bash
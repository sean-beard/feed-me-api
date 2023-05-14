FROM elixir:1.14.4

RUN apt-get update

# Install app dependencies
RUN apt-get install -y postgresql sudo inotify-tools

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY . .

RUN rm -rf deps _build

ENV SHELL /bin/bash
CMD ["sh", "/app/entrypoint.sh"]

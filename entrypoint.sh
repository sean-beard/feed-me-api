#!/bin/bash

echo "Installing dependencies..."
rm mix.lock
mix deps.get

echo "Compiling..."
mix compile

echo "Creating the database..."
mix ecto.create

echo "Running the database migrations..."
mix ecto.migrate

mix phx.server

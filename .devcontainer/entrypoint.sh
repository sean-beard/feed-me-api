#!/bin/bash

echo "Setting up database runtime dependencies..."
service postgresql start 
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" 

echo "Creating the database..."
mix ecto.create

echo "Running the database migrations..."
mix ecto.migrate

echo "Starting the server..."
mix phx.server

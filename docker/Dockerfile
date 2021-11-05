# Use an official Elixir runtime as a parent image
FROM elixir:latest

RUN apt-get update && \
  apt-get install -y postgresql-client inotify-tools ffmpeg

# Install Phoenix packages
RUN mix local.hex --force
RUN mix local.rebar --force

# Install node
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

WORKDIR /app
EXPOSE 4000

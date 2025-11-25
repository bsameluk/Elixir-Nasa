# Build stage  
FROM hexpm/elixir:1.16.0-erlang-26.1.2-debian-bookworm-20231009 AS build

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build environment
ENV MIX_ENV=prod

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Install asset compilation tools (tailwind, esbuild binaries)
RUN mix assets.setup

# Copy config (needed for assets.deploy)
COPY config config

# Copy application code FIRST (Tailwind needs to scan templates for classes!)
COPY lib lib

# Copy assets
COPY assets assets
COPY priv priv

# Compile assets (NOW Tailwind can see all the classes in your .heex files)
RUN mix assets.deploy

# Compile application
RUN mix compile

# Create release
RUN mix release

# Runtime stage
FROM debian:bookworm-slim AS app

# Install runtime dependencies
RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

# Copy release from build stage
COPY --from=build /app/_build/prod/rel/nasa_flights_calculator ./

# Copy static assets
COPY --from=build /app/priv/static ./priv/static

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser: /app
USER appuser

ENV HOME=/app

# Expose port
EXPOSE 4000

# Start the application
CMD ["bin/nasa_flights_calculator", "start"]


# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t ec_site .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name ec_site ec_site

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages (runtime only)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




# --- 開発用イメージ (dev target) --------------------------------------------
FROM base AS dev

# Development-time packages: build tools, node/yarn for js deps, sqlite3 for local DB
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git nodejs npm sqlite3 libpq-dev && \
    npm install -g yarn || true && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Development environment settings and ensure bundle binstubs are on PATH
ENV RAILS_ENV="development" \
    BUNDLE_WITHOUT="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    PATH="/usr/local/bundle/bin:/rails/bin:${PATH}"

WORKDIR /rails

# Install Ruby gems (cacheable layer)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 || true

# Copy app code
COPY . .

# Optional: prepare local DB (don't fail the image build on DB errors)
RUN if [ -f bin/rails ]; then bin/rails db:create db:migrate || true; fi

EXPOSE 3000

# Default command for dev target: start rails server bound to 0.0.0.0
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]

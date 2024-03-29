FROM ubuntu:22.04

RUN apt-get update && apt-get install -y git jq curl && rm -rf /var/lib/apt/lists/*

RUN groupadd -r unprivileged && useradd --no-log-init -r -g unprivileged unprivileged
COPY --chown=unprivileged:unprivileged . /app
USER unprivileged

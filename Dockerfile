FROM ubuntu:22.04

RUN groupadd -r unprivileged && useradd --no-log-init -r -g unprivileged unprivileged
COPY --chown=unprivileged:unprivileged . /app
USER unprivileged

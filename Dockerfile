FROM ubuntu:22.04

RUN groupadd unprivileged && useradd --no-log-init -g unprivileged unprivileged
COPY --chown=unprivileged:unprivileged . /app
USER unprivileged

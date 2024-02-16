FROM elixir:1.12.2-alpine as builder

ARG APP_NAME

ADD . /app

WORKDIR /app

ENV MIX_ENV=prod

RUN apk add git
RUN mix do \
      local.hex --force, \
      local.rebar --force, \
      deps.get, \
      deps.compile, \
      release "${APP_NAME}"

RUN git log --pretty=format:"%H %cd %s" > commits.txt

FROM alpine:3.14

ARG APP_NAME

RUN apk add --no-cache \
      tini \
      ncurses-libs \
      zlib \
      ca-certificates \
      libstdc++ \
      openssl \
      bash

WORKDIR /app

COPY --from=builder /app/_build /app
COPY --from=builder /app/commits.txt /app

ENV REPLACE_OS_VARS=true \
      APP=${APP_NAME}

ENTRYPOINT ["/sbin/tini", "--"]

CMD prod/rel/${APP}/bin/${APP} eval "Elixir.Uaddresses.ReleaseTasks.migrate" && prod/rel/${APP}/bin/${APP} start

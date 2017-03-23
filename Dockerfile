FROM nebo15/alpine-elixir:1.4.1-r0
MAINTAINER DrPandemic

ENV REFRESHED_AT 2017–03–23
ENV HOME /root

# Upgrade all packages
RUN apk — update upgrade && \
 rm -rf /var/cache/apk/*

ARG APP
ARG VERSION

ENV MIX_ENV prod
ENV PORT 4000
ENV APP_PATH _build/prod/rel/$APP
ENV APP $APP

RUN mkdir -p /$APP
COPY $APP_PATH /$APP

WORKDIR /$APP

EXPOSE $PORT

CMD trap exit TERM; bin/$APP foreground & wait

FROM crystallang/crystal:1.0.0

RUN apt-get update -qq && apt-get install -y --no-install-recommends libsqlite3-dev

CMD ["crystal", "--version"]


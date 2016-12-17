FROM crystallang/crystal:0.27.0

RUN apt-get update -qq && apt-get install -y --no-install-recommends libsqlite3-dev

CMD ["crystal", "--version"]


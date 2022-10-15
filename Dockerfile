FROM crystallang/crystal:1.6.0-alpine


RUN apk update && apk add --no-cache \
    sqlite-static \
    && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apk/*

CMD ["crystal", "--version"]


FROM alpine:3.20

RUN apk update && apk upgrade && apk add mariadb mariadb-client

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

ENTRYPOINT ["/script.sh"]

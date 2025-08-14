FROM alpine:3.20

RUN apk update \
    && apk add --no-cache \
    nginx \
    openssl \
    && mkdir -p /var/www/html/ \
    && rm /var/cache/apk/* 

COPY /tools/script.sh /
COPY /conf /etc/nginx

RUN chmod 777 /script.sh

ENTRYPOINT [ "/script.sh" ]
CMD [ "nginx", "-g", "daemon off;"]

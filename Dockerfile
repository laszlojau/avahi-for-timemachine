FROM alpine:latest
MAINTAINER laszlojau

COPY avahia.service /etc/avahi/services/timemachine.service

RUN apk add --no-cache --update avahi \
    && sed -i -r 's/^#?(enable-dbus)=yes/\1=no/g' \
                 /etc/avahi/avahi-daemon.conf \
    && rm -rf /var/cache/apk/* \
    && chmod 644 /etc/avahi/services/timemachine.service

HEALTHCHECK  --interval="5m" --timeout="3s" \
  CMD avahi-daemon -c || exit 1

ENTRYPOINT ["avahi-daemon"]

FROM alpine:latest

COPY config/ /etc/avahi/services/

RUN \
    # Install the Avahi daemon
    apk add --no-cache --update avahi \
    && rm -rf /var/cache/apk/* \
    \
    # Disable D-Bus
    && sed --in-place \
           --regexp-extended \
           --expression 's/^#?(enable-dbus)=yes/\1=no/g' \
                        /etc/avahi/avahi-daemon.conf \
    && chmod 644 /etc/avahi/services/*.service \
    \
    # Remove the services not present in the 'enabled_services' file
    && find /etc/avahi/services \
         -type f \
         $(printf "! -name %s " "$(cat /etc/avahi/services/enabled_services)") \
         -exec rm {} + \
    && rm -f /etc/avahi/services/enabled_services

EXPOSE 5353/udp

HEALTHCHECK  --interval=5m --timeout=3s \
  CMD avahi-daemon -c || exit 1

ENTRYPOINT ["avahi-daemon"]

#!/bin/sh
echo "${PORTAINER_PASSWORD}" > /tmp/pwd
/portainer/portainer --admin-password-file /tmp/pwd --data /data

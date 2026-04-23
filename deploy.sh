#!/usr/bin/env bash

SSSD_CONF=$(mktemp)
sed "s/SSSD_BIND_PASSWORD_PLACEHOLDER/$SSSD_PASS/" auth/sssd.conf > "$SSSD_CONF"

microk8s helm upgrade --install slurm \
  oci://ghcr.io/slinkyproject/charts/slurm \
  --values=config.yaml \
  --set-file "loginsets.slinky.sssdConf=$SSSD_CONF" \
  --set-file "loginsets.slinky.rootSshAuthorizedKeys=${HOME}/.ssh/id_ed25519.pub" \
  --namespace=slurm \
  --version 1.0.1

rm -f "$SSSD_CONF"
unset SSSD_PASS

# reset login pod
microk8s kubectl delete pod -n slurm -l app.kubernetes.io/component=login

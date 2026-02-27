SSSD_CONF=$(mktemp)
sed "s/SSSD_BIND_PASSWORD_PLACEHOLDER/$SSSD_PASS/" auth/sssd.conf > "$SSSD_CONF"

microk8s helm upgrade slurm \
  oci://ghcr.io/slinkyproject/charts/slurm \
  --values=config.yaml \
  --set 'loginsets.slinky.enabled=true' \
  --set-file "loginsets.slinky.rootSshAuthorizedKeys=${HOME}/.ssh/id_ed25519.pub" \
  --set-file "loginsets.slinky.sssdConf=$SSSD_CONF" \
  --namespace=slurm

rm -f "$SSSD_CONF"
unset SSSD_PASS


kubectl rollout restart -n slurm deployment/slurm-login-slinky
microk8s kubectl rollout status -n slurm deployment/slurm-login-slinky
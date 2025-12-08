#!/usr/bin/env bash
set -euo pipefail

# Always call the terraform CLI, but only keep the last field (expected to be the IP)
RAW=$(terraform output -raw public_ip 2>&1 || echo "")

# Extract something that looks like an IPv4 address from the output
IP=$(echo "$RAW" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -n1)

if [ -z "$IP" ]; then
  echo "DEBUG terraform output was:"
  echo "$RAW"
  echo "ERROR: could not extract public_ip; cannot generate inventory"
  exit 1
fi

cat > ../ansible/inventory <<EOF
[server]
${IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/hng-key
EOF

echo "Inventory generated at infra/ansible/inventory"

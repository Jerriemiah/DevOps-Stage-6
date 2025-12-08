#!/usr/bin/env bash
set -euo pipefail

# Force plain Terraform binary and strip GitHub wrapper noise
IP=$(terraform output -raw public_ip 2>/dev/null | tr -d '\r' || echo "")

# Keep only the first token that looks like an IP (strip any extra GitHub debug text)
IP=$(echo "$IP" | awk 'NF{print $1; exit}')

if [ -z "$IP" ]; then
  echo "ERROR: public_ip output is empty; cannot generate inventory"
  exit 1
fi

cat > ../ansible/inventory <<EOF
[server]
${IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/hng-key
EOF

echo "Inventory generated at infra/ansible/inventory"

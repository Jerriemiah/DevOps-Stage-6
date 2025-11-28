#!/bin/bash

IP=$(terraform output -raw public_ip)

cat <<EOF > ../ansible/inventory
[server]
${IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/hng-key
EOF

echo "Inventory generated at infra/ansible/inventory"

/*
  infra/terraform/provisioning.tf

  Purpose:
  - Trigger local inventory generation and Ansible playbook automatically after
    the aws_instance.app_server is created or when its identifying fields change.
  - Use local-exec provisioner via a null_resource with triggers for idempotence.

  NOTE:
  - This runs locally (on your machine where you run `terraform apply`).
  - Ensure ansible-playbook and the SSH key are available on the same machine.
*/

/*
resource "null_resource" "run_ansible" {
  # Ensure the null_resource runs only after the app_server exists
  depends_on = [aws_instance.app_server]

  # Triggers determine when the resource is considered changed.
  # Only when one of these values changes will the local-exec run again.
  triggers = {
    instance_id = aws_instance.app_server.id
    public_ip   = aws_instance.app_server.public_ip
  }

  provisioner "local-exec" {
    # Run inventory generator first (script lives in infra/terraform/)
    # Then run ansible-playbook using the generated inventory.
    # We disable host key checking to avoid interactive prompts during automation.
    #
    # If your generate_inventory.sh uses "~" for private key path, it's safer
    # to write out the absolute path to avoid expansion issues. The script
    # is expected to create ../ansible/inventory with ansible_user and private key path.
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -o pipefail
echo "==> Running generate_inventory.sh (from infra/terraform)..."
./generate_inventory.sh
if [ $? -ne 0 ]; then
  echo "ERROR: generate_inventory.sh failed"
  exit 1
fi

echo "==> Inventory created at infra/ansible/inventory:"
ls -l ../ansible/inventory || true
echo "==> Running Ansible playbook..."
# Disable host key checking for automation and run playbook
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory ../ansible/playbook.yml
EOT
  }

  # Optional: allow Terraform to show local-exec output even on apply
  lifecycle {
    create_before_destroy = false
  }
}
*/

resource "null_resource" "generate_inventory" {
  triggers = {
    public_ip = aws_instance.app_server.public_ip
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -o pipefail
echo "==> Running generate_inventory.sh (from infra/terraform)..."
./generate_inventory.sh
if [ $? -ne 0 ]; then
  echo "ERROR: generate_inventory.sh failed"
  exit 1
fi

echo "==> Inventory created at infra/ansible/inventory:"
ls -l ../ansible/inventory || true
EOT
  }

  depends_on = [aws_instance.app_server]
}

resource "null_resource" "run_ansible" {
  triggers = {
    # stable trigger: only changes if inventory content changes
    inventory_hash = filesha256("${path.module}/../ansible/inventory")
    instance_id    = aws_instance.app_server.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -o pipefail
echo "==> Running Ansible playbook..."
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory ../ansible/playbook.yml
EOT
  }

  depends_on = [
    null_resource.generate_inventory,
    aws_instance.app_server,
  ]

  lifecycle {
    create_before_destroy = false
  }
}

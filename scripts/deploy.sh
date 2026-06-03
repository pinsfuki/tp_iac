#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[INFO] Initialisation Terraform..."
cd "${ROOT_DIR}/terraform"
terraform init -input=false

echo "[INFO] Application Terraform..."
terraform apply -input=false -auto-approve

echo "[INFO] Exécution du playbook Ansible..."
cd "${ROOT_DIR}"
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

echo "[INFO] Déploiement terminé avec succès."

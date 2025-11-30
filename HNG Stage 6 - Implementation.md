# 🚀 HNG Stage 6 — DevOps Implementation

### **Containerised Microservices + Terraform + Ansible + CI/CD + Drift Detection + SSL + Traefik**

This repository contains the **complete end-to-end DevOps pipeline** for the HNG Stage 6 task:

* Containerized microservices
* Infrastructure-as-Code with Terraform
* Server configuration & application deployment via Ansible
* CI/CD pipelines
* Automated drift detection + email alerts
* HTTPS + Traefik reverse proxy
* Idempotent deployments
* Fully automated provisioning using a *single command*:

```
terraform apply -auto-approve
```

---

# 📁 Repository Structure

```
repo-root/
│
├── frontend/             # Vue.js frontend
├── auth-api/             # Go authentication API
├── todos-api/            # Node.js TODO service
├── users-api/            # Java Spring Boot user service
├── log-processor/        # Python log worker
├── docker-compose.yml    # Root-level compose to run everything
│
└── infra/
    ├── terraform/        # Infrastructure provisioning
    │   ├── backend.tf
    │   ├── compute.tf
    │   ├── networking.tf
    │   ├── provisioning.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── generate_inventory.sh
    │
    ├── ansible/          # Server configuration + deployment
    │   ├── inventory
    │   ├── playbook.yml
    │   └── roles/
    │       ├── setup/    # Docker, packages, etc.
    │       └── deploy/   # Clone repo, start app, Traefik, SSL
    │
    └── .github/workflows/
        ├── validate.yml  # Terraform validation
        └── infra.yml     # Plan → Drift detection → Approval → Apply
```

---

# 🧩 Application Architecture

The application is a microservices-based TODO system:

| Component     | Technology              |
| ------------- | ----------------------- |
| Frontend      | Vue.js                  |
| Auth API      | Go                      |
| Todos API     | Node.js                 |
| Users API     | Java Spring Boot        |
| Log Processor | Python                  |
| Queue         | Redis                   |
| Ingress       | Traefik (SSL + Routing) |
| Deployment    | Docker Compose          |

### 🔗 Expected Endpoints (with SSL)

```
https://app.jerrie-todo.mooo.com/
https://auth.jerrie-todo.mooo.com/
https://todos.jerrie-todo.mooo.com/
https://users.jerrie-todo.mooo.com/
```

---

# 🏗️ Infrastructure Architecture

The entire infrastructure is provisioned using Terraform:

### Components:

✔ AWS VPC
✔ Public Subnet
✔ Internet Gateway
✔ Security Group
✔ Elastic Public IP
✔ EC2 Instance (Ubuntu 24.04)
✔ Remote State Backend (S3 + DynamoDB Lock)
✔ Ansible Dynamic Inventory Generator
✔ Automated post-provision Ansible Deployment

### Network Diagram (ASCII)

```
                   ┌─────────────────────────────────────────┐
                   │                 AWS VPC                 │
                   │     10.10.0.0/16                        │
                   │                                         │
                   │   ┌──────────────────────────────────┐   │
Internet ─────────────▶│  Public Subnet 10.10.1.0/24      │   │
                   │   │                                  │   │
                   │   │  EC2 (Docker + App + Traefik)    │   │
                   │   │  Public IP: <dynamic>            │   │
                   │   └──────────────────────────────────┘   │
                   │                                         │
                   └─────────────────────────────────────────┘
```

---

# 📦 Containerisation

Each service has its own Dockerfile:

```
frontend/Dockerfile
auth-api/Dockerfile
todos-api/Dockerfile
users-api/Dockerfile
log-processor/Dockerfile
```

### Unified local startup:

```
docker compose up -d
```

### Reverse Proxy: Traefik

* Auto SSL (Let's Encrypt)
* Public HTTPS
* Routing:

```
/           → frontend
/api/auth   → auth-api
/api/todos  → todos-api
/api/users  → users-api
```

---

# 🧰 Terraform

### Features:

* Idempotent provisioning
* Remote backend: S3
* State locking: DynamoDB
* Security groups
* Key pair creation
* EC2 with Docker-ready setup
* Generates Ansible inventory dynamically
* Auto-triggers Ansible after creation

### Run Terraform locally:

```
cd infra/terraform
terraform init
terraform apply -auto-approve \
  -var="key_name=hng-key" \
  -var="public_key_path=~/.ssh/hng-key.pub"
```

---

# 🔧 Ansible

Located in `infra/ansible/`.

### Roles:

#### **1. setup/**

Installs:

* Docker
* Docker Compose
* Git
* Certificate dependencies
* System packages

#### **2. deploy/**

* Clone the repository into `/opt/app`
* Pull latest changes
* Start services via `docker compose`
* Traefik configuration
* Automatic SSL certificate provisioning
* Idempotent docker deployment
  (only restarts when something changes)

### Remote execution (done automatically by Terraform)

```
ansible-playbook -i inventory playbook.yml
```

---

# 🔄 CI/CD Pipelines

Located in `.github/workflows/`.

## 1️⃣ `validate.yml` — Terraform Formatting + Validation

Runs on every push.
Ensures code correctness.

---

## 2️⃣ `infra.yml` — FULL Infrastructure Pipeline

Triggered when:

* `infra/terraform/**` changes
* `infra/ansible/**` changes

### Pipeline stages:

### ✔ **Terraform Plan**

* Computes plan
* Captures exit code
* Determines drift

### ✔ **Drift Detection**

* Exit code **2** → DRIFT
* Sends email alert
* Halts the pipeline

### ✔ **Manual Approval**

Uses GitHub Environments.

### ✔ **Terraform Apply**

* Applies automatically if no drift
* Requires approval if drift is detected

### ✔ **Ansible Deployment**

(Triggered after Apply)

### 📨 Email Notification Integration

Uses:

```
mail -s "Terraform Drift Alert" you@example.com
```

You may replace this with:

* AWS SES
* Mailgun
* SendGrid
* Gmail SMTP

---

# ☁️ Expected Behaviours (Per HNG Requirements)

| Test                         | Expected Response                         |
| ---------------------------- | ----------------------------------------- |
| Visit domain                 | Login page loads                          |
| Login                        | Redirects to dashboard                    |
| Direct API access (no token) | Returns correct error                     |
| Auth API                     | “Not Found”                               |
| Todos API                    | “Invalid Token”                           |
| Users API                    | “Missing or invalid Authorization header” |

---

# 📸 Required Screenshots


1. Login page on your domain
2. TODO dashboard
3. Terraform apply success
4. Terraform “No changes”
5. Drift detection email alert
6. Ansible deployment output
7. Domain HTTPS with lock icon
8. CI/CD pipeline screenshot

---

# 🧪 Testing the Deployment

### Test that EC2 is reachable:

```
ssh -i ~/.ssh/hng-key ubuntu@<public-ip>
```

### Test all microservice endpoints:

```
curl -I https://your-domain.com
curl -I https://your-domain.com/api/auth
curl -I https://your-domain.com/api/todos
curl -I https://your-domain.com/api/users
```

---

# 🩺 Troubleshooting

### ❌ Terraform S3 Lock Error

If you see:

```
Error acquiring the state lock
```

Fix by releasing the lock:

```
aws dynamodb delete-item \
  --table-name hng-terraform-locks \
  --key '{"LockID": {"S": "devops/terraform.tfstate-md5"}}'
```

---


# 👨‍💻 Author

**Jerriemiah — DevOps Engineer**
HNG Internship Stage 6
2025

---


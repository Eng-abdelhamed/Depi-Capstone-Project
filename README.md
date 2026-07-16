DEPI Capstone Project

## Overview

This repository contains the source code and configuration for the ** DeployCart Capstone Project**. It demonstrates a complete DevOps pipeline for a NodeJs-based application (Nodejs -Nestjs DeployCart), including Infrastructure as Code (IaC), Configuration Management, Continuous Integration (CI), and Continuous Deployment (CD).

## Architecture

The project leverages the following technologies:

-   **Infrastructure**: AWS (provisioned via **Terraform**)
-   **Configuration Management**: **Ansible** (for K8s cluster setup and server configuration)
-   **Application**: Java Spring Boot (PetClinic)
-   **Containerization**: **Docker**
-   **CI Pipeline**: **Jenkins** (Build, Test, Push to Docker Hub)
-   **CD Pipeline**: **ArgoCD** (GitOps deployment to Kubernetes)
-   **Orchestration**: **Kubernetes** (Self-managed cluster on AWS EC2)

## Directory Structure

| Directory | Description |
| :--- | :--- |
| `terraform/` | Terraform modules and scripts to provision AWS infrastructure (VPC, EC2, RDS, etc.). |
| `ansible/` | Ansible playbooks for setting up the Kubernetes cluster and configuring servers. |
| `app-CI/` | Source code for the Java application (PetClinic) and the Dockerfile. |
| `app-CD/` | Kubernetes manifests (YAML) for deploying the application via ArgoCD. |
| `tools/` | Configuration files for DevOps tools like Jenkins and ArgoCD. |

## Prerequisites

Before you begin, ensure you have the following tools installed:

-   [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate credentials)
-   [Terraform](https://www.terraform.io/)
-   [Ansible](https://www.ansible.com/)
-   [Docker](https://www.docker.com/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Getting Started
### Automated Deployment
For a quick end-to-end deployment, navigate to the `ansible` directory and run the main deployment script. This script will provision the infrastructure, configure the Kubernetes cluster, and deploy the application workload.
```bash
cd ansible
./ansible_bastion.sh
```
> or  

### 1. Provision Infrastructure
Navigate to the `terraform` directory and apply the configuration:
```bash
cd terraform
terraform init
terraform apply
```

### 2. Configure Kubernetes Cluster
Use Ansible to set up the K8s cluster on the provisioned EC2 instances:
```bash
cd ansible
# Update inventory.ini with new IP addresses
ansible-playbook -i inventory.ini playbooks/main.yaml
```

### 3. Build and Push Application (CI)
The CI pipeline is handled by Jenkins. Ensure your Jenkins server is configured with the `Jenkinsfile` located in `tools/jenkins/`.

### 4. Deploy Application (CD)
The CD pipeline is managed by ArgoCD. Apply the application manifests:
```bash
kubectl apply -f app-CD/
```
Or configure ArgoCD to watch the `app-CD` directory of this repository.

## Presentation

[View Project Presentation]([https://www.canva.com/design/DAG6Na64jQ8?ui=eyJLIjp7IkEiOiJhMzFiNzM2My05OTE1LTQyNDctYWViNC0yMTBiY2FmZDliMTgifX0](https://www.canva.com/design/DAG6Na64jQ8/_TqJo3ryVeSur-cq0SGm0Q/edit?utm_content=DAG6Na64jQ8&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton])

## License

This project is licensed under the Apache 2.0 License.
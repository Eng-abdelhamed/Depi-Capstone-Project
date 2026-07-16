# DEPI Capstone Project | DeployCart

DeployCart is a production-grade, multi-tier Node.js web application engineered to showcase a modern, automated GitOps workflow. The project highlights cloud infrastructure-as-code, secure container pipelines, robust orchestration, and real-time observability.

---

## Architecture

![Architecture Diagram](.Architechtures_pictures/Architechture.png)

---

##  Repository Structure

The project is modularized into three main functional directories:

*   **[`APP-CI`](./APP-CI/README.md)**: Node.js application source code, Docker build configurations, and unit/integration tests.
*   **[`APP-CD`](./Application-CD/README.md)**: Kubernetes manifests and Helm charts deployed and managed continuously via ArgoCD.
*   **[`Terraform`](./Terrafrom/README.md)**: Infrastructure as Code (IaC) configurations to provision AWS resources, including Amazon VPC, EKS, and ECR.

---

##  Tech Stack & Prerequisites

Ensure you have the following CLI tools configured locally before deployment:

*   **AWS CLI v2**: To authenticate and manage AWS cloud resources.
*   **Terraform**: For provisioning and managing the cloud lifecycle.
*   **Docker**: For local container builds and multi-stage testing.
*   **Kubectl & Helm**: To interact with and deploy packages onto the Amazon EKS cluster.

---

##  Automated CI/CD Workflow

The DeployCart pipeline is designed around zero-manual-intervention deployments:


### 1. Infrastructure Provisioning (IaC)
GitHub Actions triggers **Terraform** to dynamically provision or update the core AWS infrastructure, including a highly available EKS cluster, private networks (VPCs), and IAM roles.

### 2. Continuous Integration (CI)
Our GitHub Actions pipeline builds the application container and runs security checks:
*   **Code Quality**: Analyzed by **SonarQube** to block bugs and maintainability issues.
*   **Vulnerability Scanning**: Analyzed by **Trivy** to catch CVEs in code dependencies and base OS layers.
*   **Registry Delivery**: Safely builds and pushes the hardened production image to **Amazon Elastic Container Registry (ECR)**.

### 3. Continuous Delivery (CD)
*   **ArgoCD** acts as the GitOps controller, reconciling drift between Git declarations and EKS cluster state.
*   **ArgoCD Image Updater** continuously monitors Amazon ECR for new tags and automatically commits updates directly to the Helm values inside the Git repository.

---

##  Monitoring & CD Dashboards

### Continuous Delivery Dashboard
ArgoCD actively monitors the deployment health, pulling Helm updates directly from the Git repository.

![ArgoCD Interface](.Architechtures/ArgoCD.jpeg)

### Observability & Infrastructure Monitoring
We utilize **Prometheus** and **Grafana** to monitor system resource consumption, cluster node status, and application metrics.

![Grafana Dashboard](.Architechtures_pictures/Grafana.jpeg)
![Grafana Visuals](.Architechtures_pictures/GrafanaVisuals.jpeg)

### Running Application
Once deployed, the live Node.js microservice handles traffic under an active load balancer.

![Running Application](.Architechtures_pictures/runningApp.jpeg)
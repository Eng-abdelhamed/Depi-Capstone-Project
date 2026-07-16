# Depi Capstone Project

This repository contains the source code, deployment manifests, and infrastructure configuration for the **DeployCart** application. DeployCart is a multi-tier NodeJS web application that demonstrates a modern DevOps workflow, including containerization, orchestration, and infrastructure as code.

## Architecture

![Architecture Diagram](.Architechtures_pictures/Architechture.jpeg)

## Components

The project is organized into the following directories:

- **[APP-CI](./APP-CI/README.md)**: Contains the NodeJS application source code and Docker build configuration.
- **[APP-CD](./Application-CD/README.md)**: Contains the Kubernetes manifests for deploying the application using Helm and ArgoCD.
- **[Terrafrom](./Terrafrom/README.md)**: Contains the Terraform configuration for provisioning AWS infrastructure.

## Prerequisites

Before running the application, ensure you have the following tools installed:

- **Docker**: For building container images.
- **Kubernetes CLI (kubectl)**: For interacting with the cluster.
- **Terraform**: For provisioning infrastructure.
- **AWS CLI**: For managing AWS resources.

## Automated Workflow

The application deployment is fully automated using a CI/CD pipeline:

1.  **Infrastructure Provisioning**: GitHub Actions triggers Terraform to provision the EKS cluster and other AWS resources.
2.  **Continuous Integration (CI)**: GitHub Actions builds the Docker image and pushes it to Amazon ECR After Scanning it by Trivy , Sonarqube.
3.  **Continuous Delivery (CD)**: ArgoCD watches the repository for changes and automatically syncs the application state to the EKS cluster via ArgoCD Image Updater.

### Running Application
![Running Application](.Architechtures_pictures/runningApp.jpeg)

md#secret-management).

## Monitoring & CD

### Monitoring
The project includes monitoring configurations.
![Monitoring Dashboard](.Architechtures_pictures/Grafana.jpeg)

![Monitoring Dashboard](.Architechtures_pictures/GrafanaVisuals.jpeg)

### ArgoCD
We use ArgoCD for GitOps-based continuous delivery.
![ArgoCD Interface](.Architechtures/ArgoCD.jpeg)

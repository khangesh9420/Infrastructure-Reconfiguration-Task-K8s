![diagram-export-6-11-2025-10_05_33-PM](https://github.com/user-attachments/assets/7177e358-d945-4dc2-b8d1-819386568bfd)
# 🚀 CI/CD Modernization with Terraform, AKS, Helm, ArgoCD, Buildah & Docker

This project transforms a legacy Azure VM–based Jenkins pipeline into a fully cloud-native, secure, scalable CI/CD platform.

It combines:
- Infrastructure-as-Code using **Terraform**
- **AKS** (Azure Kubernetes Service)
- Container tools: **Docker** for local dev, **Buildah** in Jenkins agents
- GitOps with **ArgoCD**
- Helm charts for app deployment and common tooling
- Monitoring & observability with **Prometheus** + **Grafana**
- Code analysis with **SonarQube**

---

## 🚧 Repository Contents

- **Infrastructure-Reconfiguration-Task-K8s**: Terraform modules + scripts to provision:
  - Azure Resource Group
  - Virtual Network and Subnets
  - AKS Cluster
  - AD, Key Vault, Storage, etc.
- **Infrastructure_manifest_K8**: Kubernetes YAML manifests and Helm values for:
  - Sample applications (from your app repo)
  - Jenkins (with Buildah)
  - ArgoCD
  - SonarQube
  - Prometheus + Grafana
- **Dockerfile**: Used for local Docker testing
- **Jenkins pipeline**: Uses **Buildah** inside containerized agents

---

## 🔁 Workflow Overview

1. **Terraform import** (for any legacy VM you want to manage)
2. **Terraform apply** to build AKS + infra
3. **Helm / manifest** deploy Jenkins, ArgoCD, Sonar, Prometheus, Grafana
4. **Jenkins pipeline** builds using Buildah, pushes containers
5. **ArgoCD** syncs manifests to deploy apps
6. **Monitoring & Observability** onboarded via Prom/Grafana

---

## 🧱 Step‑by‑Step Guide

### 1. Import legacy Azure VM (optional)

```bash
az login
VM_ID=$(az vm show -g <resource-group> -n <vm-name> --query id -o tsv)

cat > import_vm.tf <<EOF
resource "azurerm_virtual_machine" "jenkins_vm" {
  name                = "<vm-name>"
  resource_group_name = "<resource-group>"
  location            = "<region>"
}
EOF

terraform init
terraform import azurerm_virtual_machine.jenkins_vm "$VM_ID"
terraform plan
terraform apply
```

---

### 2. Provision AKS & Supporting Resources

1. Clone repo:
   ```bash
   git clone https://github.com/khangesh9420/Infrastructure-Reconfiguration-Task-K8s.git
   cd Infrastructure-Reconfiguration-Task-K8s
   ```

2. Review `main.tf` for:
   - Resource Group, VNet, Subnets
   - AKS setup
   - Azure AD, Key Vault, Storage

3. Apply Terraform:
   ```bash
   terraform init
   terraform apply
   ```

4. Connect to AKS:
   ```bash
   az aks get-credentials -g <rg> -n <aks-name>
   kubectl get nodes
   ```

---

### 3. Dockerfile (Local Build)

Use the provided Dockerfile to test locally:

```bash
docker build -t sample-app .
docker run -p 8080:8080 sample-app
```

---

### 4. Jenkins with Buildah (CI Pipeline)

- **Why Buildah?**  
  Buildah allows building containers in unprivileged mode (no Docker daemon), ideal in Kubernetes.

- Sample Jenkinsfile:
   ```groovy
   pipeline {
     agent {
       kubernetes {
         yamlFile 'jenkins-agent-buildah-pod.yaml'
       }
     }
     stages {
       stage('Build') {
         steps {
           container('buildah') {
             sh 'buildah bud -t sample-app:${BUILD_NUMBER} .'
             sh 'buildah push docker://<your-registry>/sample-app:${BUILD_NUMBER}'
           }
         }
       }
       stage('SonarQube') { ... }
       stage('Deploy') { ... }
     }
   }
   ```

---

### 5. Deploy Jenkins, ArgoCD, SonarQube, Prometheus, Grafana via Helm

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add oteemocharts https://oteemo.github.io/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Deploy
helm install jenkins jenkins/jenkins -n jenkins --create-namespace
helm install argocd argo/argo-cd -n argocd --create-namespace
helm install sonarqube oteemocharts/sonarqube -n sonar --create-namespace
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

---

### 6. ArgoCD GitOps

```bash
argocd app create my-app   --repo https://github.com/khangesh9420/Infrastructure_manifest_K8   --path ./app-deployments   --dest-server https://kubernetes.default.svc   --dest-namespace default
argocd app sync my-app
```

---

### 7. Monitoring & Observability

- Prometheus scrapes Jenkins, app, and node metrics
- Grafana dashboards preconfigured
- SonarQube handles code analysis
- Trivy scans for container vulnerabilities

---

## ✅ Benefits

- No single point of failure
- Autoscaled Jenkins agents with Buildah
- GitOps CD via ArgoCD
- Terraform-managed, auditable infra
- Fully observable and secure CI/CD

---

## 📂 Project Layout

```
├── Infrastructure-Reconfiguration-Task-K8s/
│   └── main.tf, modules/
├── Infrastructure_manifest_K8/
│   └── manifests, Helm values
├── Dockerfile
├── Jenkinsfile
└── README.md
```

---

## 🤝 Let's Connect

This repo is part of my personal DevOps transformation journey. Fork, adapt, or reach out on [LinkedIn](https://www.linkedin.com/in/khangesh9420/)!

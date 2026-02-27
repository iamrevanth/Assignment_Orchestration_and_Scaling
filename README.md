# Assignment 08 - DevOps: Kubernetes + HELM + Jenkins CI/CD

This project demonstrates the end-to-end deployment of a **MERN (MongoDB, Express.js, React.js, Node.js)** stack application using **Kubernetes**, **HELM**, and **Jenkins** automation on an **Amazon EC2** instance.

## 📁 Repository Structure

``` text
Assignment_08_DevOps/
├── backend/ # Node.js + Express backend code
├── frontend/ # React frontend code
├── helm/learner-report # HELM chart for deployment
├── output-logs # Output logs and post-script
├── wip # Jenkins Files Work In Progress via Local Docker and without driver=docker during minikube start
├── Jenkinsfile # Jenkins Groovy script for full CI/CD automation
└── README.md # Project documentation
```


---

## 🚀 Features

- Dockerized **frontend** and **backend**
- Kubernetes deployment manifests for both services
- HELM chart for flexible and reusable deployments
- Jenkins pipeline to:
  - SSH into EC2
  - Install Docker, Minikube, kubectl, Helm
  - Build Docker images
  - Push images to Docker Hub
  - Generate and deploy HELM charts
- MongoDB Atlas integration using environment variables

---

## 🔧 Technologies Used

- **Kubernetes** (Minikube on EC2)
- **HELM 3**
- **Jenkins (Groovy scripted pipeline)**
- **Docker + Docker Hub**
- **Node.js**, **React.js**
- **MongoDB Atlas**

---

## ⚙️ Setup Overview

### 1. Backend & Frontend Dockerization
- Each service has its own `Dockerfile` for independent container builds.

### 2. Kubernetes Deployment
- Separate YAML manifests for `Deployment`, `Service`, `ConfigMap`, and `Secrets` are templated using HELM.

### 3. HELM Chart
- Located under `/helm-chart`
- Parameterized values using `values.yaml`
- Handles both frontend and backend deployments in a single chart

### 4. EC2 Instance Requirements for Jenkins-Based MERN Deployment

This project requires a properly configured EC2 instance for deploying the MERN stack application using Jenkins, Docker, Minikube, and Helm.

## 🔧 EC2 Instance Configuration

- **Instance Type:** `t3.medium`
  - 2 vCPUs
  - 4 GB RAM  
  - ✅ Suitable for running Minikube with 2 CPUs & 2GB memory

- **Storage:** `30 GB` (gp2 or gp3)
  - ⚠️ Minimum 30 GB required to avoid running out of space for libraries or Docker image build or Minikube startup failures

- **Operating System:** `Ubuntu 22.04 LTS` (or Ubuntu 20.04 LTS)

- **Network & Access:**
  - Allow inbound traffic on:
    - **Port 3100** – Frontend access
    - **Port 3101** – Backend access
    - **Port 22** – SSH for Jenkins to connect
  - Elastic IP recommended for stable access

---

## 📝 Note

This configuration is essential for ensuring:
- Smooth Minikube cluster setup
- Successful Jenkins SSH automation
- Reliable CI/CD execution


### 5. Jenkins Pipeline (Jenkinsfile)
- Automates entire deployment flow:

```text
Pipeline
   ↓
Stage: Git Pull
   ↓
Task: Clones the GitHub repository (frontend, backend)
   ↓
Stage: SSH into EC2 & Setup Tools
   ↓
Task: SSH into EC2 instance using Jenkins credentials
   ↓
Task: Install dependencies on EC2:
     - Docker
     - Minikube
     - kubectl
     - Helm
     - curl
     - git
     - apt-transport-https
     - software-properties-common
     - conntrack
     - daemonize
   ↓
Stage: Build & Push Docker Images to Docker Hub
   ↓
Task: Build Docker images:
     - Backend image from backend/Dockerfile
     - Frontend image from frontend/Dockerfile
   ↓
Task: Push Docker images to Docker Hub:
     - Uses credentials stored in Jenkins
   ↓
Stage: Create imagePullSecret in Kubernetes
   ↓
Task: Creating docker-hub-secret for use in Kubernetes
   ↓
Stage: Generate Helm Charts & Deploy
   ↓
Task: Generate HELM chart values dynamically:
     - Injects MongoDB URI, HASH_KEY, JWS_SECRET_KEY, API base URL
   ↓
Task: Deploy application to Minikube using HELM:
     - `helm upgrade --install mern-app ./helm-chart`
   ↓
Stage: Post-Deploy Validation
   ↓
Verify the Deployments and Print in Jenkins Console
   ↓
Wait for the Pods to Run Successfuly and Print the Accessible Endpoint URL
(Note: Jenkins Masks this Value)
   ↓
Task Expose services via NodePort and print access URL with the Public IP Address of EC2 Instance

```

---

## 🔐 Environment Variables (Managed in Jenkins Credentials)

``` text
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| Variable Name                                | Purpose                                      | Sample Values                                                                                         |
|----------------------------------------------|----------------------------------------------|--------------------------------------------------------------------------------------------------------
| `JL_ASSIGNMENT_EIGHT_MONGO_ATLAS_URI`        | MongoDB connection string                    | mongodb+srv://userid:password@cluster0.aorqndq.mongodb.net/learner_report?retryWrites=true&w=majority |
| `JL_ASSIGNMENT_EIGHT_HASH_KEY`               | JWT hash key for backend auth                | thisIsMyHashKey                                                                                       |
| `JL_ASSIGNMENT_EIGHT_JWS_SECRET_KEY`         | JWS secret key                               | thisIsMyJwtSecretKey                                                                                  |
| `JL_ASSIGNMENT_EIGHT_EC2_IP_ADDRESS`         | EC2 instance IP                              | 65.0.139.200                                                                                          |
| `JL_ASSIGNMENT_EIGHT_DOCKER_REPOSITORY_NAME` | Docker Hub repo                              | https://hub.docker.com/repositories/devopspikachu                                                     |
| `JL_EC2_USER`                                | EC2 User Name                                | ubuntu                                                                                                |
| `JL_WORK_RELATED_EMAIL_ADDRESS`              | Valid Working Email Address for Docker       | test1234@gmail.com                                                                                    |
| `JL_EC2_SSH_PRIVATE_KEY`                     | Username Password Key For SSH Connect        | BEGIN RSA PRIVATE KEY ASD3432....                                                                     |
| `JL_DOCKERHUB_CREDS`                         | Username Password Key For Docker Connect     | Username: devopspikachu and Password: <DOCKER-PAT-TOKEN_PLACEHOLDER>                                  |
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
```

## ⚙️ Commands Executed in Jenkins Pipeline with Description


```text
🔹 System & Tool Installation (on EC2)
```
```bash

# command: Update system package list
sudo apt-get update -y

# command: Install Docker, Git, curl, and other dependencies
sudo apt-get install -y docker.io curl git apt-transport-https software-properties-common conntrack daemonize

# command: Add ubuntu user to docker group to run Docker without sudo
sudo usermod -aG docker ubuntu

# command: Fix file protection issue for Kubernetes
sudo sysctl fs.protected_regular=0
```

```text
🔹 Install Kubernetes CLI Tools
```
```bash

# command: Download kubectl binary
curl -LO https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl

# command: Make kubectl executable and move to system path
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# command: Download Minikube binary
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# command: Make Minikube executable and move to system path
chmod +x minikube && sudo mv minikube /usr/local/bin/

# command: Install Helm 3 using official script
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

```
```text
🔹 Clean Existing Minikube Setup
```
```bash

# command: Delete any existing Minikube cluster
minikube delete --all --purge || true

# command: Remove previous Kubernetes config
rm -rf ~/.minikube ~/.kube

```
```text
🔹 Start New Minikube Cluster
```
```bash

# command: Start a fresh Minikube cluster using Docker driver
minikube start --driver=docker --cpus=2 --memory=2048 --force --wait-timeout=5m0s || minikube logs

```
```text
🔹 Clone GitHub Repository
```
```bash

# command: Create working directory and move into it
mkdir -p ~/devops8 && cd ~/devops8

# command: Remove existing cloned repo if any
rm -rf Assignment_08_DevOps

# command: Clone the GitHub repository
git clone $REPO

```
```text
🔹 Docker Image Build & Push
```
```bash

# command: Login to Docker Hub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# command: Create backend config.env file
cat <<EOT > backend/config.env
ATLAS_URI=${MONGO}
HASH_KEY=${HASH}
JWT_SECRET_KEY=${JWT}
EOT

# command: Create frontend .env file with API base URL
cat <<EOT > frontend/.env
REACT_APP_API_BASE_URL=http://${SSH_IP}:${PORT}
EOT

# command: Build and push backend Docker image
cd backend
docker build -t ${BACKEND}:${BACKEND_TAG} .
docker push ${BACKEND}:${BACKEND_TAG}

# command: Build and push frontend Docker image
cd ../frontend
docker build -t ${FRONTEND}:${FRONTEND_TAG} .
docker push ${FRONTEND}:${FRONTEND_TAG}

```
```text
🔹 Kubernetes Secret for Docker Hub (imagePullSecret)
```
```bash

# command: Delete existing secret if it exists
kubectl delete secret docker-hub-secret --ignore-not-found

# command: Create new Docker registry secret for pulling private images
kubectl create secret docker-registry docker-hub-secret \
  --docker-username="$DOCKER_USERNAME" \
  --docker-password="$DOCKER_PASSWORD" \
  --docker-email="$DOCKER_EMAIL"

```
```text
🔹 Helm Chart Generation & Deployment
```
```bash

# command: Create Helm chart for backend and frontend
helm create backend
helm create frontend

# command: Remove Helm test templates
rm -rf backend/templates/tests frontend/templates/tests

# command: Generate backend values.yaml file with env vars and image details
cat <<EOT > backend/values.yaml
...
EOT

# command: Generate frontend values.yaml file with env vars and image details
cat <<EOT > frontend/values.yaml
...
EOT

# command: Deploy backend using Helm
helm upgrade --install backend ./backend

# command: Deploy frontend using Helm
helm upgrade --install frontend ./frontend

```
```text
🔹 Post-Deployment Validation
```
```bash

# command: List deployed Helm releases
helm list

# command: Get all Kubernetes resources (pods, services, etc.)
minikube kubectl -- get all

# command: Wait for backend pod readiness and port-forward
kubectl get pods -l app.kubernetes.io/name=backend
daemonize -o backend.log -e backend.err \
  /usr/local/bin/kubectl port-forward svc/backend 3101:3001 --address=0.0.0.0

# command: Wait for frontend pod readiness and port-forward
kubectl get pods -l app.kubernetes.io/name=frontend
daemonize -o frontend.log -e frontend.err \
  /usr/local/bin/kubectl port-forward svc/frontend 3100:3000 --address=0.0.0.0

```
```text
✅ Access URLs
```

Frontend URL:
```text
http://<EC2-PUBLIC-IP>:3100
```

Backend URL:
```text
http://<EC2-PUBLIC-IP>:3101
```

## 📸 Screenshots

![IMG_01](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_01.png)
![IMG_02](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_02.png)
![IMG_03](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_03.png)
![IMG_04](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_04.png)
![IMG_05](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_05.png)
![IMG_06](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_06.png)
![IMG_07](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_07.png)
![IMG_08](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_08.png)
![IMG_09](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_09.png)
![IMG_10](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_10.png)
![IMG_11](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_11.png)
![IMG_12](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_12.png)
![IMG_13](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_13.png)
![IMG_14](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_14.png)
![IMG_15](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_15.png)
![IMG_16](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_16.png)
![IMG_17](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_17.png)
![IMG_18](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_18.png)
![IMG_19](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_19.png)
![IMG_20](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_20.png)
![IMG_21](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_21.png)
![IMG_22](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_22.png)
![IMG_23](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_23.png)
![IMG_24](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_24.png)
![IMG_25](https://github.com/JOYSTON-LEWIS/My-Media-Repository/blob/main/Assignment_08_DevOps_Outputs_Images/IMG_25.png)

---

## 📜 License
This project is licensed under the MIT License.

## 🤝 Contributing
Feel free to fork and improve the scripts! ⭐ If you find this project useful, please consider starring the repo—it really helps and supports my work! 😊

## 📧 Contact
For any queries, reach out via GitHub Issues.

---

🎯 **Thank you for reviewing this project! 🚀**

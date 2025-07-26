# Caso Práctico 2 – Infraestructura IaC (Terraform + Ansible)

Este proyecto crea:

1. **Resource Group**
2. **Azure Container Registry** (ACR) y sube dos imágenes:
   - `casopractico2:web-amd64` (Nginx estático)
   - `casopractico2:app-amd64` (WordPress + Apache PHP 8.2)
3. **AKS** con permiso **AcrPull**
4. Despliegue en AKS de:
   - **MariaDB** (PVC)
   - **WordPress** (PVC)
   - **Nginx** (ClusterIP)

---

## 0 · Requisitos previos

| Herramienta | Versión mínima | Instalación sugerida |
|-------------|---------------|----------------------|
| Git | 2.30 | `sudo apt install git` · `brew install git` |
| Azure CLI | 2.61 | <https://aka.ms/InstallAzureCli> |
| Terraform | 1.8 | `brew install terraform` |
| Podman (o Docker) | 5.x | `brew install podman && podman machine init && podman machine start` |
| kubectl | 1.30 | `brew install kubernetes-cli` |
| Python | 3.11+ | Incluido en Homebrew/macOS |

---

## 1 · Clonar el repositorio

```bash
git clone https://github.com/<TU_USUARIO>/DevOpsCP2.git
cd DevOpsCP2

## 2 · Iniciar sesión en Azure

## 3 · Cerar entorno virtual y dependencias

python3 -m venv ~/ansible-venv
source ~/ansible-venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
ansible-galaxy collection install containers.podman kubernetes.core

Activar entorno siempre que abras otra terminal:
source ~/ansible-venv/bin/activate

## 4 · Terraform - ACR y AKS
cd terraform
echo 'acr_name = "miacrúnico123"' > terraform.tfvars
terraform init
terraform apply

Guardar kubeconfig:

mkdir -p ~/.kube
terraform output -raw kubeconfig > ~/.kube/aks_cp2.conf

## 5 · Variables de entorno para la sesión

source ~/ansible-venv/bin/activate
export K8S_AUTH_KUBECONFIG=~/.kube/aks_cp2.conf

export ACR_LOGIN_SERVER=$(terraform -chdir=terraform output -raw acr_login_server)
export ACR_USER=$(terraform -chdir=terraform output -raw acr_admin_username)
export ACR_PASS=$(terraform -chdir=terraform output -raw acr_admin_password)

## 6 · Construir y subir imágenes al ACR

cd ansible
ansible-playbook -i hosts playbook.yml \
  -e ansible_python_interpreter=$(which python)

## 7 · Desplegar en AKS

ansible-playbook -i hosts playbook_aks.yml \
  -e ansible_python_interpreter=$(which python)

## 8 · Comprobar

kubectl --kubeconfig ~/.kube/aks_cp2.conf -n casopractico2 get pods
kubectl --kubeconfig ~/.kube/aks_cp2.conf -n casopractico2 get svc wordpress



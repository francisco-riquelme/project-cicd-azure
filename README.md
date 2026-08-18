# ApiGo CI/CD — Azure + Terraform + GitHub Actions

Proyecto de referencia DevOps que despliega una API en **Go** sobre **Azure Container Apps**, con imágenes en **Azure Container Registry (ACR)**, infraestructura como código con **Terraform** y pipeline CI/CD en **GitHub Actions** autenticado mediante **OIDC** (sin secretos de larga duración).

## Arquitectura

```text
Developer
   │  git push (master)
   ▼
GitHub Actions (OIDC → Entra ID)
   │  docker build (multistage)
   │  docker push
   ▼
Azure Container Registry
   │  pull (Managed Identity + AcrPull)
   ▼
Azure Container Apps  ──►  HTTPS /health /users
```

| Capa | Tecnología |
|---|---|
| Aplicación | Go 1.22, API HTTP JSON |
| Contenedores | Docker multistage → Distroless |
| Registry | Azure Container Registry |
| Runtime | Azure Container Apps (escala 0–3) |
| IaC | Terraform + módulos reutilizables |
| Estado remoto | Azure Storage (blob `tfstate`) |
| Secretos | Azure Key Vault + GitHub Secrets (OIDC) |
| CI/CD | GitHub Actions |

## Estructura del repositorio

```text
.
├── app/                      # API Go + Dockerfile
├── infra/
│   ├── bootstrap/            # RG, Storage (tfstate), Key Vault
│   ├── envs/dev/             # Entorno de desarrollo (backend remoto)
│   └── modules/
│       ├── acr/
│       └── container-apps/
└── .github/workflows/
    └── ci-cd.yml             # Build → Push ACR → Deploy Container App
```

## Endpoints

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/` | Info del servicio |
| `GET` | `/health` | Health check |
| `GET` | `/users` | Listado de usuarios de prueba |

URL pública (dev):

`https://ca-apigo-cicd-dev.graycoast-7062f1e8.eastus.azurecontainerapps.io`

## Requisitos

- Azure CLI autenticado (`az login`)
- Terraform ≥ 1.5
- Go ≥ 1.22
- Docker Desktop / Engine
- Git + cuenta GitHub

## 1. Bootstrap (estado remoto + Key Vault)

Crea el Resource Group, Storage Account para el `tfstate`, contenedor blob y Key Vault.

```powershell
cd infra/bootstrap
Copy-Item terraform.tfvars.example terraform.tfvars
# Edita nombres (Storage: solo a-z0-9; Key Vault: único global)

terraform init
terraform plan
terraform apply
```

> El bootstrap usa **estado local** a propósito. El Storage que crea se usa después como backend remoto de `envs/dev`.

## 2. Backend remoto + infraestructura de runtime

```powershell
cd infra/envs/dev
Copy-Item backend.hcl.example backend.hcl
Copy-Item terraform.tfvars.example terraform.tfvars
# Ajusta nombres / imagen / réplicas

terraform init "-backend-config=backend.hcl"
terraform plan
terraform apply
```

Recursos principales:

- ACR (admin deshabilitado)
- Log Analytics
- Container Apps Environment
- Container App + User Assigned Identity con rol **AcrPull**

Si la suscripción no tiene registrado el provider:

```powershell
az provider register --namespace Microsoft.App
```

## 3. Aplicación local

```powershell
cd app
go run .
curl.exe http://localhost:8080/health
curl.exe http://localhost:8080/users
```

Build de imagen:

```powershell
cd app
docker build -t apigo-cicd:local .
docker run --rm -p 8080:8080 apigo-cicd:local
```

## 4. CI/CD (GitHub Actions + OIDC)

En cada push a `master`/`main` que toque `app/**`:

1. Login a Azure con OIDC  
2. Login a ACR  
3. Build multistage + push (`:sha` y `:latest`)  
4. `az containerapp update` con la nueva imagen  

### Secrets de GitHub

| Secret | Descripción |
|---|---|
| `AZURE_CLIENT_ID` | App Registration (Application ID) |
| `AZURE_TENANT_ID` | Tenant de Entra ID |
| `AZURE_SUBSCRIPTION_ID` | ID de la suscripción |

La App Registration debe tener:

- Federated credential hacia el repo/branch (subject OIDC de GitHub)
- Rol **AcrPush** sobre el ACR
- Rol **Contributor** (o equivalente) sobre el Resource Group

Plantilla del federated credential: `infra/bootstrap/github-oidc-federated.json`

> En algunas cuentas GitHub el subject incluye IDs (`user@id/repo@id`). Debe coincidir **exactamente** con el valor configurado en Entra ID.

## Buenas prácticas aplicadas

- Estado de Terraform remoto, versionado y privado  
- Separación bootstrap / entorno (`envs/dev`)  
- Módulos Terraform reutilizables  
- ACR sin admin user; pull con Managed Identity  
- Imagen mínima (Distroless, usuario nonroot)  
- CI/CD con OIDC (sin client secrets permanentes)  
- Tags consistentes en recursos Azure  
- Secretos y `*.tfvars` / `backend.hcl` fuera de Git  

## Flujo de trabajo recomendado

1. Cambiar código en `app/`  
2. `git push` a `master`  
3. Revisar GitHub Actions  
4. Validar `/health` y `/users` en la URL pública  

Cambios de infraestructura: `terraform plan/apply` en `infra/envs/dev` (o ampliar el pipeline con un job de IaC).

## Autor

Francisco Riquelme — proyecto de aprendizaje / portafolio DevOps sobre Azure.

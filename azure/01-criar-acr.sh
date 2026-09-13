#!/bin/bash
# ============================================================
# PetHealthAPI - Script 1: Resource Group + Azure Container Registry
# Challenge FIAP 2026 - DevOps Tools & Cloud Computing
# ============================================================
set -e  # para o script imediatamente se qualquer comando falhar

RESOURCE_GROUP="rg-pethealth-devops"
LOCATION="chilecentral"
ACR_NAME="acrpethealthdevops"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${CYAN}===> $1${NC}"; }
ok()   { echo -e "${GREEN}[OK] $1${NC}"; }
warn() { echo -e "${YELLOW}[!]  $1${NC}"; }
fail() { echo -e "${RED}[ERRO] $1${NC}"; exit 1; }

step "Verificando registro do provedor Microsoft.ContainerRegistry"
STATE=$(az provider show --namespace Microsoft.ContainerRegistry --query registrationState -o tsv)
if [ "$STATE" != "Registered" ]; then
  warn "Provedor nao registrado (estado: $STATE). Registrando..."
  az provider register --namespace Microsoft.ContainerRegistry
  fail "Registro iniciado — aguarde alguns minutos e rode este script novamente."
fi
ok "Provedor Microsoft.ContainerRegistry registrado."

step "Verificando login na Azure"
if ! az account show > /dev/null 2>&1; then
  warn "Você ainda não está logado. Abrindo navegador..."
  az login
fi
ok "Login confirmado. Subscription ativa:"
az account show --query "{nome:name}" -o table

step "Criando Resource Group '$RESOURCE_GROUP' em $LOCATION"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output table
ok "Resource Group criado."

step "Criando Azure Container Registry '$ACR_NAME'"
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled true \
  --output table
ok "ACR criado."

step "Obtendo credenciais do ACR"
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)

echo ""
echo -e "${GREEN}=============================================================${NC}"
echo -e "${GREEN}  RESOURCE GROUP E ACR CRIADOS COM SUCESSO!${NC}"
echo -e "${GREEN}=============================================================${NC}"
echo -e "Resource Group : ${CYAN}$RESOURCE_GROUP${NC}"
echo -e "ACR Name       : ${CYAN}$ACR_NAME${NC}"
echo -e "ACR Login Srv  : ${CYAN}$ACR_LOGIN_SERVER${NC}"
echo -e "ACR Username   : ${CYAN}$ACR_USERNAME${NC}"
echo ""
echo -e "${YELLOW}Guarde o Login Server acima — vamos usar no proximo script.${NC}"
echo -e "${GREEN}=============================================================${NC}"
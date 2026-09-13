#!/bin/bash
# ============================================================
# PetHealthAPI - Script 4: ACI da API .NET
# Challenge FIAP 2026 - DevOps Tools & Cloud Computing
# ============================================================
set -e

RESOURCE_GROUP="rg-pethealth-devops"
ACR_NAME="acrpethealthdevops"
ACI_ORACLE_NAME="aci-pethealth-oracle"
ACI_API_NAME="aci-pethealth-api"
API_DNS_LABEL="pethealth-api-$RANDOM"
IMAGE_NAME="pethealthapi"
IMAGE_TAG="v1"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${CYAN}===> $1${NC}"; }
ok()   { echo -e "${GREEN}[OK] $1${NC}"; }
fail() { echo -e "${RED}[ERRO] $1${NC}"; exit 1; }

if [ -z "$ORACLE_PASSWORD" ]; then
  fail "Variavel ORACLE_PASSWORD nao definida. Rode: export ORACLE_PASSWORD='SuaSenhaForte123' (a mesma usada no script 3)"
fi

step "Obtendo dados do ACR"
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
FULL_IMAGE="$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"
ok "Imagem: $FULL_IMAGE"

step "Obtendo FQDN do Oracle"
ORACLE_FQDN=$(az container show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_ORACLE_NAME" \
  --query ipAddress.fqdn -o tsv)
ok "Oracle em: $ORACLE_FQDN"

CONNECTION_STRING="User Id=pethealth;Password=${ORACLE_PASSWORD};Data Source=${ORACLE_FQDN}:1521/XEPDB1;"

step "Criando Container Instance da API: $ACI_API_NAME"
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_API_NAME" \
  --image "$FULL_IMAGE" \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --ports 8080 \
  --dns-name-label "$API_DNS_LABEL" \
  --registry-login-server "$ACR_LOGIN_SERVER" \
  --registry-username "$ACR_USERNAME" \
  --registry-password "$ACR_PASSWORD" \
  --environment-variables ASPNETCORE_ENVIRONMENT=Production \
  --secure-environment-variables ConnectionStrings__OracleConnection="$CONNECTION_STRING" \
  --output table
ok "ACI da API criado."

step "Obtendo FQDN da API"
API_FQDN=$(az container show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_API_NAME" \
  --query ipAddress.fqdn -o tsv)

echo ""
echo -e "${GREEN}=============================================================${NC}"
echo -e "${GREEN}  ACI DA API CRIADO COM SUCESSO!${NC}"
echo -e "${GREEN}=============================================================${NC}"
echo -e "Nome do ACI   : ${CYAN}$ACI_API_NAME${NC}"
echo -e "FQDN          : ${CYAN}$API_FQDN${NC}"
echo -e "Swagger       : ${CYAN}http://$API_FQDN:8080${NC}"
echo -e "Health check  : ${CYAN}http://$API_FQDN:8080/health${NC}"
echo -e "${GREEN}=============================================================${NC}"
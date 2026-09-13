#!/bin/bash
# ============================================================
# PetHealthAPI - Script 3: ACI do Oracle (banco de dados em nuvem)
# Challenge FIAP 2026 - DevOps Tools & Cloud Computing
# ============================================================
set -e

RESOURCE_GROUP="rg-pethealth-devops"
LOCATION="chilecentral"
ACI_ORACLE_NAME="aci-pethealth-oracle"
ORACLE_DNS_LABEL="pethealth-oracle-$RANDOM"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${CYAN}===> $1${NC}"; }
ok()   { echo -e "${GREEN}[OK] $1${NC}"; }
warn() { echo -e "${YELLOW}[!]  $1${NC}"; }

if [ -z "$ORACLE_PASSWORD" ]; then
  fail() { echo -e "\033[0;31m[ERRO] $1\033[0m"; exit 1; }
  fail "Variavel ORACLE_PASSWORD nao definida. Rode: export ORACLE_PASSWORD='SuaSenhaForte123'"
fi

step "Criando Container Instance do Oracle: $ACI_ORACLE_NAME"
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_ORACLE_NAME" \
  --image docker.io/gvenzl/oracle-xe:21-slim \
  --os-type Linux \
  --cpu 2 \
  --memory 4 \
  --ports 1521 \
  --dns-name-label "$ORACLE_DNS_LABEL" \
  --environment-variables \
      ORACLE_PASSWORD="$ORACLE_PASSWORD" \
      APP_USER=pethealth \
      APP_USER_PASSWORD="$ORACLE_PASSWORD" \
  --output table
ok "ACI do Oracle criado."

step "Obtendo FQDN do Oracle"
ORACLE_FQDN=$(az container show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_ORACLE_NAME" \
  --query ipAddress.fqdn -o tsv)

echo ""
echo -e "${GREEN}=============================================================${NC}"
echo -e "${GREEN}  ACI DO ORACLE CRIADO COM SUCESSO!${NC}"
echo -e "${GREEN}=============================================================${NC}"
echo -e "Nome do ACI   : ${CYAN}$ACI_ORACLE_NAME${NC}"
echo -e "FQDN          : ${CYAN}$ORACLE_FQDN${NC}"
echo -e "Porta         : ${CYAN}1521${NC}"
echo ""
echo -e "${YELLOW}O Oracle pode levar de 2 a 5 minutos para terminar de inicializar.${NC}"
echo -e "${YELLOW}Acompanhe com:${NC}"
echo -e "   ${CYAN}az container logs --resource-group $RESOURCE_GROUP --name $ACI_ORACLE_NAME --follow${NC}"
echo -e "${GREEN}=============================================================${NC}"
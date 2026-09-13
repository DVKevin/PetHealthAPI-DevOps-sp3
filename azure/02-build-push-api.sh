#!/bin/bash
# ============================================================
# PetHealthAPI - Script 2: Build e Push da imagem da API para o ACR
# Challenge FIAP 2026 - DevOps Tools & Cloud Computing
# ============================================================
set -e

ACR_NAME="acrpethealthdevops"
IMAGE_NAME="pethealthapi"
IMAGE_TAG="v1"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${CYAN}===> $1${NC}"; }
ok()   { echo -e "${GREEN}[OK] $1${NC}"; }

ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
FULL_IMAGE="$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"

step "Fazendo login no ACR '$ACR_NAME' via Docker"
az acr login --name "$ACR_NAME"
ok "Login no ACR realizado."

step "Build da imagem local: $IMAGE_NAME:$IMAGE_TAG"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .
ok "Imagem buildada localmente."

step "Aplicando tag para o ACR: $FULL_IMAGE"
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$FULL_IMAGE"
ok "Tag aplicada."

step "Enviando (push) a imagem para o ACR"
docker push "$FULL_IMAGE"
ok "Push concluido."

echo ""
echo -e "${GREEN}=============================================================${NC}"
echo -e "${GREEN}  IMAGEM PUBLICADA NO ACR COM SUCESSO!${NC}"
echo -e "${GREEN}=============================================================${NC}"
echo -e "Imagem completa: ${CYAN}$FULL_IMAGE${NC}"
echo -e "${GREEN}=============================================================${NC}"
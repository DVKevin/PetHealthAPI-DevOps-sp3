# 🐾 Pet Health API

> **FIAP — Challenge 2026 | DevOps Tools & Cloud Computing**
> Advanced Business Development with .NET

---

## 📋 Descrição da Solução

A **Pet Health API** é uma API RESTful desenvolvida em **ASP.NET Core (.NET 8)**, criada como parte do Challenge 2026 da FIAP em parceria com a **CLYVO VET**.

A API centraliza o cadastro de **tutores, pets, vacinas, consultas e medicamentos**, permitindo o gerenciamento completo da jornada de saúde de um pet: quem é o responsável, quais animais ele possui, e o histórico de cuidados de cada um.

Nesta Sprint de **DevOps Tools & Cloud Computing**, a aplicação foi containerizada e implantada na nuvem Azure, com banco de dados Oracle também containerizado e publicado via Azure Container Instances, seguindo a arquitetura **ACR + ACI**.

## 💼 Benefícios para o Negócio

- **Elimina a fragmentação de informação**: hoje, tutores e clínicas perdem histórico de vacinas e consultas por falta de um sistema centralizado — a API resolve isso com um cadastro único e relacional.
- **Reduz esquecimento de vacinas/retornos**: os endpoints de "vacinas vencendo" e "retornos agendados" permitem que a clínica atue de forma proativa, aumentando a recorrência de atendimento.
- **Escalabilidade e disponibilidade**: rodando containerizada na Azure, a solução pode ser replicada e escalada conforme a demanda da clínica cresce, sem depender de infraestrutura própria.
- **Portabilidade**: como toda a stack (API + banco) roda em containers Docker, o mesmo ambiente pode ser reproduzido em qualquer máquina ou provedor de nuvem, sem "funciona na minha máquina".

---

## ☁️ Arquitetura da Solução (Azure)

**Opção escolhida: ACR + ACI (Azure Container Registry + Azure Container Instances)**

```
┌─────────────────────────────────────────────────────────────┐
│                         Azure (Cloud)                        │
│                                                                │
│  ┌──────────────────────┐                                    │
│  │  Azure Container      │   docker push                     │
│  │  Registry (ACR)        │◄──────────────┐                  │
│  │  acrpethealthdevops    │                │                  │
│  └──────────┬─────────────┘                │                  │
│             │ docker pull                  │                  │
│             ▼                              │                  │
│  ┌──────────────────────┐         ┌────────┴─────────┐        │
│  │  ACI - PetHealthAPI    │  HTTP  │  Máquina Local    │        │
│  │  (.NET 8, porta 8080)  │◄───────┤  (build/push da   │        │
│  │  IP público             │        │  imagem)          │        │
│  └──────────┬─────────────┘         └───────────────────┘      │
│             │ Oracle (porta 1521, via FQDN)                   │
│             ▼                                                  │
│  ┌──────────────────────┐                                    │
│  │  ACI - Oracle XE       │                                    │
│  │  (banco de dados)      │                                    │
│  │  IP público             │                                    │
│  └────────────────────────┘                                    │
└─────────────────────────────────────────────────────────────┘
```

**Como funciona:**
1. A imagem Docker da API é buildada localmente e enviada (`docker push`) para o **Azure Container Registry (ACR)**.
2. Um **Azure Container Instance (ACI)** é criado para o **Oracle XE**, com IP público e porta 1521 exposta — este é o banco de dados em nuvem da aplicação.
3. Um segundo **ACI** é criado para a **API**, puxando a imagem do ACR e configurado com a string de conexão apontando para o FQDN do ACI do Oracle.
4. A comunicação entre API e Banco acontece via rede pública da Azure, usando o FQDN gerado automaticamente para o container do Oracle.

**Recursos Azure criados (todos via Azure CLI):**

| Recurso | Nome | Finalidade |
|---|---|---|
| Resource Group | `rg-pethealth-devops` | Agrupa todos os recursos da solução |
| Azure Container Registry | `acrpethealthdevops` | Armazena a imagem Docker da API |
| Container Instance | `aci-pethealth-oracle` | Executa o banco Oracle XE containerizado |
| Container Instance | `aci-pethealth-api` | Executa a API .NET containerizada |

---

## 🏗️ Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|---|---|---|
| ASP.NET Core | .NET 8 | Framework principal da API |
| Entity Framework Core | 8.0 | ORM para mapeamento das entidades |
| Oracle.EntityFrameworkCore | 8.21.121 | Driver de conexão com Oracle |
| Swashbuckle (Swagger) | 6.5.0 | Documentação OpenAPI |
| Oracle Database (gvenzl/oracle-xe:21-slim) | 21c | Banco de dados containerizado |
| Docker / Docker Compose | — | Containerização da aplicação e do banco |
| Azure CLI | — | Provisionamento de todos os recursos na nuvem |
| Serilog.AspNetCore | 10.0.0 | Logging estruturado |
| OpenTelemetry | 1.18.0 | Tracing e métricas distribuídas |
| xUnit / Moq / FluentAssertions | — | Testes automatizados |

---

## 🗄️ Modelo de Banco de Dados

```
TB_PH_TUTOR (1) ──── (N) TB_PH_PET
                              │
              ┌───────────────┼──────────────────┐
              │               │                  │
        TB_PH_VACINA   TB_PH_CONSULTA   TB_PH_MEDICAMENTO
```

O DDL completo (tabelas, colunas, chaves, comentários) está em [`script_bd.sql`](./script_bd.sql), na raiz do repositório.

**CRUD demonstrado nesta atividade:** `Tutor` + `Pet` (tabelas relacionadas via `ID_TUTOR`), com as operações de Inclusão, Consulta, Alteração e Exclusão validadas ponta a ponta contra o banco em nuvem.

---

## 🐳 Como Executar Localmente (Docker Compose)

### Pré-requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### Passo a passo

**1. Clone o repositório**
```bash
git clone https://github.com/DVKevin/PetHealthAPI-DevOps-sp3.git
cd PetHealthAPI-DevOps-sp3
```

**2. Crie o arquivo `.env` na raiz do projeto** (não vai para o Git — contém a senha do banco):
```
ORACLE_PASSWORD=SuaSenhaLocalAqui
```

**3. Suba a API e o banco juntos**
```bash
docker compose up -d --build
```

Aguarde 2-5 minutos na primeira execução (o Oracle XE precisa inicializar). Acompanhe com:
```bash
docker compose logs -f
```
Espere a mensagem `DATABASE IS READY TO USE!`.

**4. Crie o schema no banco** (usando um cliente SQL como DBeaver, conectando em `localhost:1522`, Service Name `XEPDB1`, usuário `pethealth`), executando o [`script_bd.sql`](./script_bd.sql).

**5. Acesse o Swagger**
```
http://localhost:8080
```

**6. Verifique a saúde da aplicação**
```
http://localhost:8080/health
```

---

## ☁️ Deploy na Azure (passo a passo)

Todos os recursos são criados via **Azure CLI**, usando os scripts versionados na pasta [`azure/`](./azure/). Pré-requisito: [Azure CLI instalado](https://learn.microsoft.com/pt-br/cli/azure/install-azure-cli) e uma assinatura Azure ativa.

### 1. Criar o Resource Group e o Azure Container Registry
```bash
chmod +x azure/01-criar-acr.sh
./azure/01-criar-acr.sh
```
Cria o Resource Group `rg-pethealth-devops` e o ACR `acrpethealthdevops`.

### 2. Build e push da imagem da API para o ACR
```bash
chmod +x azure/02-build-push-api.sh
./azure/02-build-push-api.sh
```
Builda a imagem Docker da API (a partir do `Dockerfile` na raiz) e envia para o ACR.

### 3. Criar o ACI do banco Oracle
```bash
export ORACLE_PASSWORD="SuaSenhaForteAqui123#"
chmod +x azure/03-criar-aci-oracle.sh
./azure/03-criar-aci-oracle.sh
```
Cria um Container Instance rodando Oracle XE, com IP público. Acompanhe a inicialização com:
```bash
az container logs --resource-group rg-pethealth-devops --name aci-pethealth-oracle --follow
```
Espere `DATABASE IS READY TO USE!` antes de prosseguir.

### 4. Criar o schema no Oracle da nuvem
Entre no container do Oracle via Azure CLI e execute o script direto do repositório:
```bash
az container exec --resource-group rg-pethealth-devops --name aci-pethealth-oracle --exec-command "/bin/bash"
curl -L -o /tmp/script_bd.sql https://raw.githubusercontent.com/DVKevin/PetHealthAPI-DevOps-sp3/main/script_bd.sql
sqlplus pethealth/SuaSenhaForteAqui123#@//localhost:1521/XEPDB1 @/tmp/script_bd.sql
```
(No Windows, se o comando `az container exec` der erro de caminho, prefixe com `MSYS_NO_PATHCONV=1`.)

### 5. Criar o ACI da API
```bash
export ORACLE_PASSWORD="SuaSenhaForteAqui123#"   # a mesma do passo 3
chmod +x azure/04-criar-aci-api.sh
./azure/04-criar-aci-api.sh
```
Cria o Container Instance da API, já configurado com a connection string (via variável de ambiente segura) apontando para o Oracle criado no passo 3.

### 6. Acessar a aplicação na nuvem
O script 4 mostra ao final o FQDN da API. Acesse:
```
http://<fqdn-da-api>:8080          → Swagger
http://<fqdn-da-api>:8080/health   → Health Check
```

### 7. Limpeza dos recursos (ao final dos testes)
```bash
az group delete --name rg-pethealth-devops --yes --no-wait
```

---

## 📮 Testes via Postman

Sequência recomendada, usando o Swagger ou Postman contra a API publicada na Azure:

1. **Inclusão** — `POST /api/tutores` (cria um tutor)
2. **Inclusão** — `POST /api/pets` (cria 2 pets vinculados ao tutor, via `tutorId`)
3. **Consulta** — `GET /api/tutores` (confirma tutor + pets relacionados)
4. **Alteração** — `PUT /api/pets/{id}` (atualiza dados de um pet)
5. **Consulta** — `GET /api/pets/{id}` (confirma a alteração persistida)
6. **Exclusão** — `DELETE /api/pets/{id}` (remove um pet)
7. **Consulta** — `GET /api/tutores` (confirma que o pet não aparece mais)

Cada uma dessas operações pode ser comprovada diretamente no banco com `SELECT * FROM TB_PH_TUTOR` / `SELECT * FROM TB_PH_PET`, executado via `sqlplus` dentro do próprio container do Oracle na Azure (veja o comando de conexão na seção de deploy acima).

---

## 📂 Estrutura do Projeto

```
PetHealthAPI.sln
├── Dockerfile
├── docker-compose.yml
├── script_bd.sql
├── azure/
│   ├── 01-criar-acr.sh
│   ├── 02-build-push-api.sh
│   ├── 03-criar-aci-oracle.sh
│   └── 04-criar-aci-api.sh
├── src/
│   └── PetHealthAPI/
│       ├── Controllers/
│       ├── Data/AppDbContext.cs
│       ├── Models/
│       ├── appsettings.json
│       └── Program.cs
└── tests/
    ├── PetHealthAPI.Tests.Unit/
    └── PetHealthAPI.Tests.Integration/
```

---

## 📡 Principais Endpoints

### 👤 Tutores — `/api/tutores`

| Método | Rota | Descrição | HTTP |
|--------|------|-----------|------|
| GET | `/api/tutores` | Lista todos os tutores | 200 |
| GET | `/api/tutores/{id}` | Busca tutor por ID | 200 / 404 |
| POST | `/api/tutores` | Cadastra novo tutor | 201 / 400 |
| PUT | `/api/tutores/{id}` | Atualiza dados do tutor | 204 / 400 / 404 |
| DELETE | `/api/tutores/{id}` | Remove tutor | 204 / 404 |

### 🐶 Pets — `/api/pets`

| Método | Rota | Descrição | HTTP |
|--------|------|-----------|------|
| GET | `/api/pets` | Lista todos os pets | 200 |
| GET | `/api/pets/{id}` | Busca pet por ID | 200 / 404 |
| POST | `/api/pets` | Cadastra novo pet | 201 / 400 |
| PUT | `/api/pets/{id}` | Atualiza dados do pet | 204 / 400 / 404 |
| DELETE | `/api/pets/{id}` | Remove pet | 204 / 404 |

### 🩺 Monitoramento

| Método | Rota | Descrição | HTTP |
|--------|------|-----------|------|
| GET | `/health` | Verifica saúde da API e do Oracle | 200 / 503 |

---

## 👥 Integrantes

| Nome | RM |
|---|---|
| Matheus Arazin de Oliveira | 556649 |
| Artur Pioli Silva | 565597 |
| Kevin Martins Campos | 563454 |
| Pedro Gabriel Claes | 566058 |

---

*Challenge 2026 — FIAP × CLYVO VET*

# ============================================================
# PetHealthAPI - Dockerfile
# Challenge FIAP 2026 - DevOps Tools & Cloud Computing
# ============================================================

# ---------- Etapa 1: build ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia só os arquivos de projeto primeiro (melhora cache do Docker)
COPY PetHealthAPI.sln .
COPY src/PetHealthAPI/PetHealthAPI.csproj src/PetHealthAPI/
COPY tests/PetHealthAPI.Tests.Unit/PetHealthAPI.Tests.Unit.csproj tests/PetHealthAPI.Tests.Unit/
COPY tests/PetHealthAPI.Tests.Integration/PetHealthAPI.Tests.Integration.csproj tests/PetHealthAPI.Tests.Integration/

RUN dotnet restore src/PetHealthAPI/PetHealthAPI.csproj

# Copia o resto do código e publica só o projeto da API
COPY src/PetHealthAPI/ src/PetHealthAPI/
WORKDIR /src/src/PetHealthAPI
RUN dotnet publish -c Release -o /app/publish --no-restore

# ---------- Etapa 2: runtime ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Cria um usuario e grupo sem privilegios administrativos
RUN groupadd -r petapp && useradd -r -g petapp petapp

COPY --from=build /app/publish .

# Garante que o usuario petapp seja dono dos arquivos da aplicacao
RUN chown -R petapp:petapp /app

# Troca para o usuario sem privilegios (requisito 8.2 do enunciado)
USER petapp

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "PetHealthAPI.dll"]
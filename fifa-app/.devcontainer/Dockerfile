FROM mcr.microsoft.com/devcontainers/python:3.11

# Instalar dependencias del sistema si fueran necesarias
RUN apt-get update && apt-get install -y nginx

# Establecer el directorio de trabajo
WORKDIR /workspaces/fifa-app
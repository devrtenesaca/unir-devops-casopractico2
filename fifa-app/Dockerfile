FROM mcr.microsoft.com/devcontainers/python:3.11

# 2. Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# 3. Copiamos el archivo de dependencias primero (mejor para la caché de Docker)
COPY requirements.txt .

# 4. Instalamos las librerías necesarias
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copiamos el código de nuestra aplicación (el archivo app.py)
COPY app.py .

# 6. Exponemos el puerto en el que corre Flask
EXPOSE 5000

# 7. Comando para ejecutar la aplicación
# Usamos python app.py porque tu código ya tiene el app.run(host='0.0.0.0')
CMD ["python", "app.py"]
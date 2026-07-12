FROM python:3.11-slim

# 2. Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# 2.2 isntalacion de nginx
RUN apt update && \
    apt install -y nginx openssl && \
    # ELIMINAR LA CONFIGURACIÓN POR DEFECTO AQUÍ
    rm /etc/nginx/sites-enabled/default && \
    rm -rf /var/lib/apt/lists/*

# Esto crea una llave privada y un certificado válido por 365 días
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=UNIR/OU=DevOps/CN=localhost"

# 3. Copiamos el archivo de dependencias primero (mejor para la caché de Docker)
COPY requirements.txt .

# 4. Instalamos las librerías necesarias
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# 5. Copiamos el código de nuestra aplicación (el archivo app.py)
COPY app.py .

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY webserver.sh /webserver.sh
RUN chmod +x /webserver.sh
# 6. Exponemos el puerto en el que corre Flask
EXPOSE 443

# 7. Comando para ejecutar la aplicación
# Usamos python app.py porque tu código ya tiene el app.run(host='0.0.0.0')
CMD ["/webserver.sh"]


FROM node:18-alpine

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S catalog -u 1001

# Crear directorio de aplicación
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install --only=production && npm cache clean --force

# Copiar código fuente
COPY . .

# Cambiar ownership al usuario no-root
RUN chown -R catalog:nodejs /app
USER catalog

# Exponer puerto
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/healthz', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Comando de inicio
CMD ["node", "server.js"]

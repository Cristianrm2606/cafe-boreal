FROM node:18-alpine

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S orders -u 1001

# Crear directorio de aplicación
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install --only=production && npm cache clean --force

# Copiar código fuente
COPY . .

# Cambiar ownership al usuario no-root
RUN chown -R orders:nodejs /app
USER orders

# Exponer puerto
EXPOSE 3002

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3002/healthz', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Comando de inicio
CMD ["node", "server.js"]

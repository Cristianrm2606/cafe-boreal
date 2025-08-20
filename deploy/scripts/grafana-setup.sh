#!/bin/bash

GRAFANA_URL="http://localhost:5555"
GRAFANA_USER="admin"
GRAFANA_PASS="admin123"

echo "=== Configurando Grafana ==="

# Esperar a que Grafana esté disponible
echo "Esperando a Grafana..."
while ! curl -s $GRAFANA_URL > /dev/null; do
    echo "Grafana no disponible, esperando..."
    sleep 5
done

echo "✅ Grafana disponible"

# Configurar datasource de Prometheus
echo "Configurando datasource Prometheus..."
curl -X POST \
  $GRAFANA_URL/api/datasources \
  -H 'Content-Type: application/json' \
  -u $GRAFANA_USER:$GRAFANA_PASS \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus-service:9090",
    "access": "proxy",
    "isDefault": true
  }'

# Configurar datasource de Loki
echo "Configurando datasource Loki..."
curl -X POST \
  $GRAFANA_URL/api/datasources \
  -H 'Content-Type: application/json' \
  -u $GRAFANA_USER:$GRAFANA_PASS \
  -d '{
    "name": "Loki",
    "type": "loki",
    "url": "http://loki-service:3100",
    "access": "proxy"
  }'

echo "✅ Datasources configurados"
echo "🌐 Grafana disponible en: $GRAFANA_URL"
echo "👤 Usuario: $GRAFANA_USER"
echo "🔑 Password: $GRAFANA_PASS"

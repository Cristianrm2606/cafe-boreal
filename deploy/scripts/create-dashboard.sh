#!/bin/bash

GRAFANA_URL="http://localhost:5555"
GRAFANA_USER="admin"
GRAFANA_PASS="admin123"

echo "=== Creando Dashboard de Café Boreal ==="

# Dashboard JSON
cat > dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Café Boreal - Monitoring",
    "tags": ["kubernetes", "cafe-boreal"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage por Pod",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{namespace=\"cafe-boreal\"}[5m]) * 100",
            "legendFormat": "{{pod}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Memory Usage por Pod",
        "type": "stat",
        "targets": [
          {
            "expr": "container_memory_usage_bytes{namespace=\"cafe-boreal\"} / 1024 / 1024",
            "legendFormat": "{{pod}} MB"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Logs por Aplicación",
        "type": "logs",
        "targets": [
          {
            "expr": "{namespace=\"cafe-boreal\"}",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 8}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  },
  "overwrite": false
}
EOF

# Crear dashboard
curl -X POST \
  $GRAFANA_URL/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -u $GRAFANA_USER:$GRAFANA_PASS \
  -d @dashboard.json

echo "✅ Dashboard creado"
echo "🌐 Accede a: $GRAFANA_URL/d/"

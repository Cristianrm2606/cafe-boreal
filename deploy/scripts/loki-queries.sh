#!/bin/bash

echo "=== Consultas de Ejemplo para Loki en Grafana ==="
echo ""
echo "🔍 CONSULTAS ÚTILES PARA COPIAR EN GRAFANA:"
echo ""
echo "1. Todos los logs del namespace cafe-boreal:"
echo '   {namespace="cafe-boreal"}'
echo ""
echo "2. Logs solo de APIs:"
echo '   {namespace="cafe-boreal", app=~"catalog-api|orders-api|customers-api"}'
echo ""
echo "3. Logs de errores:"
echo '   {namespace="cafe-boreal"} |= "error" or "Error" or "ERROR"'
echo ""
echo "4. Logs por aplicación específica:"
echo '   {namespace="cafe-boreal", app="catalog-api"}'
echo '   {namespace="cafe-boreal", app="orders-api"}'
echo '   {namespace="cafe-boreal", app="customers-api"}'
echo ""
echo "5. Logs de PostgreSQL:"
echo '   {namespace="cafe-boreal", app="postgres"}'
echo ""
echo "📊 Para usar en Grafana:"
echo "1. Ve a http://localhost:5555"
echo "2. Explora > Loki datasource"
echo "3. Copia y pega las consultas de arriba"
echo "4. Aplica filtros por tiempo"

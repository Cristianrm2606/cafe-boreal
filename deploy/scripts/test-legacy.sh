#!/bin/bash

echo "=== Probando Módulo Legado (Apache + PHP) ==="

echo "1. Health check:"
curl -s "http://localhost:8081/?action=health" | jq '.' || echo "Error en health check"

echo -e "\n2. Inventario (5 productos):"
curl -s "http://localhost:8081/?action=inventory&limit=5" | jq '.summary' || echo "Error en inventario"

echo -e "\n3. Búsqueda por SKU 'Boreal':"
curl -s "http://localhost:8081/?action=inventory&sku=Boreal" | jq '.data[] | {name, stock, price}' || echo "Error en búsqueda"

echo -e "\n4. Estadísticas de stock:"
curl -s "http://localhost:8081/?action=stats" | jq '.stock_levels[] | {level, count, total_value}' || echo "Error en stats"

echo -e "\n5. Top productos por valor:"
curl -s "http://localhost:8081/?action=stats" | jq '.top_products_by_value[] | {name, total_value}' || echo "Error en top productos"

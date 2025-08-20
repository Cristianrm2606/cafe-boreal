#!/bin/bash

echo "=== Probando APIs con port-forward ==="

echo "1. Health checks:"
echo "  Catalog API:"
curl -s http://localhost:8001/healthz | jq '.' || echo "Error en Catalog"

echo "  Orders API:"
curl -s http://localhost:8002/healthz | jq '.' || echo "Error en Orders"

echo "  Customers API:"
curl -s http://localhost:8003/healthz | jq '.' || echo "Error en Customers"

echo -e "\n2. Productos (primeros 3):"
curl -s http://localhost:8001/products | jq '.data[0:3] | .[] | {id, name, price, stock}' || echo "Error obteniendo productos"

echo -e "\n3. Clientes (primeros 3):"
curl -s http://localhost:8003/customers | jq '.data[0:3] | .[] | {id, name, email, identity}' || echo "Error obteniendo clientes"

echo -e "\n4. Pedidos:"
curl -s http://localhost:8002/orders | jq '.data[] | {id, customer_name, total, status}' || echo "Error obteniendo pedidos"

echo -e "\n=== Probando con NodePort del Ingress ==="
MINIKUBE_IP=$(minikube ip)
echo "Probando con $MINIKUBE_IP:31884"

echo "5. Health check via Ingress:"
curl -s http://$MINIKUBE_IP:31884/api/catalog/healthz || echo "Ingress no funciona"

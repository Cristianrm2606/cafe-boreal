#!/bin/bash

echo "=== Pruebas de Carga - Café Boreal ==="

# Configuración
CATALOG_URL="http://localhost:8001"
ORDERS_URL="http://localhost:8002"
CUSTOMERS_URL="http://localhost:8003"

echo "1. Prueba básica con curl (ab no disponible, usamos curl en loop)"

# Función para prueba de carga simple
run_load_test() {
    local url=$1
    local name=$2
    local requests=$3
    
    echo "📊 Probando $name - $requests requests"
    start_time=$(date +%s)
    
    for i in $(seq 1 $requests); do
        curl -s "$url" > /dev/null &
        # Limitar concurrencia a 10
        if (( i % 10 == 0 )); then
            wait
        fi
    done
    wait
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    rps=$((requests / duration))
    
    echo "✅ $name: $requests requests en ${duration}s (${rps} req/s)"
}

# Prueba 1: Catálogo (lectura intensiva)
echo -e "\n=== PERFIL 1: Lectura intensiva (Catálogo) ==="
run_load_test "$CATALOG_URL/products" "Catalog API" 50

# Prueba 2: Clientes (con descifrado)
echo -e "\n=== PERFIL 2: Operaciones con cifrado (Clientes) ==="
run_load_test "$CUSTOMERS_URL/customers" "Customers API" 30

# Pruebas de salud
echo -e "\n=== Health Checks bajo carga ==="
run_load_test "$CATALOG_URL/healthz" "Catalog Health" 100
run_load_test "$ORDERS_URL/healthz" "Orders Health" 100
run_load_test "$CUSTOMERS_URL/healthz" "Customers Health" 100

# Estadísticas finales
echo -e "\n=== Estadísticas de rendimiento ==="
echo "📈 Métricas recolectadas en Prometheus: http://localhost:9090"
echo "📊 Dashboard disponible en Grafana: http://localhost:5555"

# Verificar respuesta de APIs después de la carga
echo -e "\n=== Verificación post-carga ==="
echo "Catalog response time:"
time curl -s "$CATALOG_URL/products" | jq '.count' || echo "Error"

echo "Orders response time:"
time curl -s "$ORDERS_URL/orders" | jq '.count' || echo "Error"

echo "Customers response time:"
time curl -s "$CUSTOMERS_URL/customers" | jq '.count' || echo "Error"

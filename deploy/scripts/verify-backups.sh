#!/bin/bash

echo "=== Verificación de Backups ==="

# Crear backup de prueba
echo "1. Creando backup..."
cd ~/cafe-boreal/deploy/scripts
./backup-restore.sh backup

# Listar backups disponibles
echo -e "\n2. Backups disponibles:"
./backup-restore.sh list

# Verificar que el backup contiene datos
echo -e "\n3. Verificando contenido del backup más reciente:"
LATEST_BACKUP=$(ls -t /tmp/backups/cafeboreal_backup_*.sql 2>/dev/null | head -1)

if [ -f "$LATEST_BACKUP" ]; then
    echo "✅ Backup encontrado: $LATEST_BACKUP"
    echo "📊 Líneas en backup: $(wc -l < "$LATEST_BACKUP")"
    echo "📦 Tamaño: $(du -h "$LATEST_BACKUP" | cut -f1)"
    
    # Verificar que contiene nuestros datos
    if grep -q "Café Boreal Clásico" "$LATEST_BACKUP"; then
        echo "✅ Backup contiene datos de productos"
    else
        echo "❌ Backup no contiene datos esperados"
    fi
    
    if grep -q "encrypt_identity" "$LATEST_BACKUP"; then
        echo "✅ Backup contiene funciones de cifrado"
    else
        echo "❌ Backup no contiene funciones de cifrado"
    fi
else
    echo "❌ No se encontró backup"
fi

echo -e "\n4. Estado de la base de datos actual:"
kubectl exec -i -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal -c "
SELECT 
    (SELECT COUNT(*) FROM products) as productos,
    (SELECT COUNT(*) FROM customers) as clientes,
    (SELECT COUNT(*) FROM orders) as pedidos;
"

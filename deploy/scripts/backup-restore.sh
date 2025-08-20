#!/bin/bash

# Configuración
NAMESPACE="cafe-boreal"
DB_NAME="cafeboreal"
DB_USER="postgres"
BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Función para backup
backup_database() {
    echo "=== Iniciando backup de base de datos ==="
    mkdir -p $BACKUP_DIR
    
    kubectl exec -n $NAMESPACE deployment/postgres -- pg_dump -U $DB_USER -d $DB_NAME > $BACKUP_DIR/cafeboreal_backup_$DATE.sql
    
    if [ $? -eq 0 ]; then
        echo "✅ Backup exitoso: $BACKUP_DIR/cafeboreal_backup_$DATE.sql"
        ls -lh $BACKUP_DIR/cafeboreal_backup_$DATE.sql
    else
        echo "❌ Error en backup"
        exit 1
    fi
}

# Función para restore
restore_database() {
    if [ -z "$1" ]; then
        echo "Uso: $0 restore <archivo_backup.sql>"
        echo "Backups disponibles:"
        ls -la $BACKUP_DIR/*.sql 2>/dev/null || echo "No hay backups disponibles"
        exit 1
    fi
    
    BACKUP_FILE="$1"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ Archivo de backup no encontrado: $BACKUP_FILE"
        exit 1
    fi
    
    echo "=== Iniciando restore de base de datos ==="
    echo "⚠️  Esto sobrescribirá todos los datos actuales"
    read -p "¿Continuar? (y/N): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        kubectl exec -i -n $NAMESPACE deployment/postgres -- psql -U $DB_USER -d $DB_NAME < "$BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            echo "✅ Restore exitoso desde: $BACKUP_FILE"
        else
            echo "❌ Error en restore"
            exit 1
        fi
    else
        echo "Restore cancelado"
    fi
}

# Función para listar backups
list_backups() {
    echo "=== Backups disponibles ==="
    ls -la $BACKUP_DIR/*.sql 2>/dev/null || echo "No hay backups disponibles"
}

# Menú principal
case "$1" in
    "backup")
        backup_database
        ;;
    "restore")
        restore_database "$2"
        ;;
    "list")
        list_backups
        ;;
    *)
        echo "Uso: $0 {backup|restore|list}"
        echo "  backup                    - Crear backup de la base de datos"
        echo "  restore <archivo.sql>     - Restaurar desde backup"
        echo "  list                      - Listar backups disponibles"
        exit 1
        ;;
esac

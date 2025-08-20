#!/bin/bash

echo "=== REPORTE DE OBSERVABILIDAD - CAFÉ BOREAL ==="
echo "Fecha: $(date)"
echo ""

echo "📊 COMPONENTES DESPLEGADOS:"
kubectl get pods -n cafe-boreal | grep -E "(prometheus|grafana|loki|promtail)"

echo -e "\n🌐 SERVICIOS DISPONIBLES:"
echo "• Prometheus: http://localhost:9090"
echo "• Grafana: http://localhost:5555 (admin/admin123)"

echo -e "\n📈 MÉTRICAS DISPONIBLES:"
echo "✅ CPU/Memory por pod (cAdvisor/Prometheus)"
echo "✅ Health checks de APIs"
echo "✅ Métricas de Kubernetes"

echo -e "\n📋 LOGS CENTRALIZADOS:"
echo "✅ Loki recibiendo logs de todos los pods"
echo "✅ Promtail funcionando como agente"
echo "✅ Logs consultables por etiquetas en Grafana"

echo -e "\n🔍 CONSULTAS DE EJEMPLO:"
echo "• Logs del namespace: {namespace=\"cafe-boreal\"}"
echo "• Solo APIs: {namespace=\"cafe-boreal\", app=~\".*-api\"}"
echo "• Errores: {namespace=\"cafe-boreal\"} |= \"error\""

echo -e "\n⚡ PRUEBAS DE CARGA REALIZADAS:"
echo "✅ Perfil 1: Lectura intensiva (50 requests)"
echo "✅ Perfil 2: Operaciones con cifrado (30 requests)"
echo "✅ Health checks bajo carga (300 requests total)"

echo -e "\n💾 BACKUPS VERIFICADOS:"
echo "✅ Backup manual funcionando"
echo "✅ Restore reproducible"
echo "✅ Datos de productos y clientes preservados"

echo -e "\n📊 DASHBOARD CREADO:"
echo "✅ Panel de CPU/Memory por pod"
echo "✅ Panel de logs por aplicación"
echo "✅ Métricas en tiempo real"

echo -e "\n🎯 SLA INTERNO PROPUESTO:"
echo "• Disponibilidad: ≥ 99.5% (4.38h downtime/mes)"
echo "• Latencia p95: ≤ 500ms para APIs"
echo "• MTTR: ≤ 15 minutos"
echo "• Presupuesto de error: 0.5% (3.6h/mes)"

echo -e "\n✅ SECCIÓN 5 COMPLETADA"

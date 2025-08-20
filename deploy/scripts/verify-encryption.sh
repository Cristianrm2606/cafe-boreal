#!/bin/bash
echo "=== Verificando productos (total: 20) ==="
kubectl exec -i -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal -c "SELECT COUNT(*) as total_products FROM products;"

echo -e "\n=== Primeros 5 productos ==="
kubectl exec -i -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal -c "SELECT id, name, price, stock FROM products LIMIT 5;"

echo -e "\n=== Verificando clientes con identidades CIFRADAS ==="
kubectl exec -i -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal -c "SELECT id, name, email, encrypted_identity FROM customers LIMIT 3;"

echo -e "\n=== Verificando DESCIFRADO de identidades ==="
kubectl exec -i -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal -c "SELECT id, name, email, decrypt_identity(encrypted_identity, 'CafeBoreal2025SecretKey123456789012') as decrypted_identity FROM customers LIMIT 3;"

echo -e "\n=== Verificando pedidos ==="
kubectl exec -i -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal -c "SELECT o.id, c.name, o.total, o.status FROM orders o JOIN customers c ON o.customer_id = c.id;"

echo -e "\n=== Conteo total ==="
kubectl exec -i -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal -c "SELECT 'Products' as table_name, COUNT(*) as count FROM products UNION ALL SELECT 'Customers', COUNT(*) FROM customers UNION ALL SELECT 'Orders', COUNT(*) FROM orders;"

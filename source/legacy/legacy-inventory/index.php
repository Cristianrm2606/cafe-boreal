<?php
require_once 'config.php';

setJSONHeaders();

// Manejar preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Obtener parámetros
$action = $_GET['action'] ?? 'inventory';
$sku = $_GET['sku'] ?? null;
$limit = intval($_GET['limit'] ?? 50);

try {
    $pdo = getDBConnection();
    
    if (!$pdo) {
        throw new Exception("No se pudo conectar a la base de datos");
    }
    
    switch ($action) {
        case 'inventory':
            handleInventory($pdo, $sku, $limit);
            break;
            
        case 'health':
            handleHealth($pdo);
            break;
            
        case 'stats':
            handleStats($pdo);
            break;
            
        default:
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'error' => 'Acción no válida. Use: inventory, health, stats'
            ]);
    }
    
} catch (Exception $e) {
    error_log("Error en Legacy API: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Error interno del servidor',
        'details' => $e->getMessage()
    ]);
}

function handleInventory($pdo, $sku, $limit) {
    $sql = "SELECT id, name, price, stock, 
                   CASE 
                       WHEN stock > 50 THEN 'Alto'
                       WHEN stock > 20 THEN 'Medio'
                       WHEN stock > 0 THEN 'Bajo'
                       ELSE 'Agotado'
                   END as stock_level,
                   (price * stock) as total_value
            FROM products";
    
    $params = [];
    
    if ($sku) {
        $sql .= " WHERE name ILIKE ? OR id::text = ?";
        $params = ["%$sku%", $sku];
    }
    
    $sql .= " ORDER BY stock DESC, name LIMIT ?";
    $params[] = $limit;
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $products = $stmt->fetchAll();
    
    // Calcular estadísticas
    $totalProducts = count($products);
    $totalValue = array_sum(array_column($products, 'total_value'));
    $lowStock = array_filter($products, fn($p) => $p['stock'] <= 20);
    
    echo json_encode([
        'success' => true,
        'system' => 'Legacy Inventory System',
        'version' => APP_VERSION,
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => $products,
        'summary' => [
            'total_products' => $totalProducts,
            'total_inventory_value' => number_format($totalValue, 2),
            'low_stock_items' => count($lowStock),
            'query_sku' => $sku
        ]
    ]);
}

function handleHealth($pdo) {
    $stmt = $pdo->query("SELECT COUNT(*) as product_count FROM products");
    $result = $stmt->fetch();
    
    echo json_encode([
        'success' => true,
        'status' => 'operational',
        'system' => APP_NAME,
        'version' => APP_VERSION,
        'database' => 'connected',
        'products_in_db' => $result['product_count'],
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}

function handleStats($pdo) {
    // Estadísticas por nivel de stock
    $stmt = $pdo->query("
        SELECT 
            CASE 
                WHEN stock > 50 THEN 'Alto'
                WHEN stock > 20 THEN 'Medio'
                WHEN stock > 0 THEN 'Bajo'
                ELSE 'Agotado'
            END as level,
            COUNT(*) as count,
            AVG(price) as avg_price,
            SUM(price * stock) as total_value
        FROM products 
        GROUP BY (CASE 
                WHEN stock > 50 THEN 'Alto'
                WHEN stock > 20 THEN 'Medio'
                WHEN stock > 0 THEN 'Bajo'
                ELSE 'Agotado'
            END)
        ORDER BY 
            (CASE 
                WHEN (CASE 
                    WHEN stock > 50 THEN 'Alto'
                    WHEN stock > 20 THEN 'Medio'
                    WHEN stock > 0 THEN 'Bajo'
                    ELSE 'Agotado'
                END) = 'Alto' THEN 1
                WHEN (CASE 
                    WHEN stock > 50 THEN 'Alto'
                    WHEN stock > 20 THEN 'Medio'
                    WHEN stock > 0 THEN 'Bajo'
                    ELSE 'Agotado'
                END) = 'Medio' THEN 2
                WHEN (CASE 
                    WHEN stock > 50 THEN 'Alto'
                    WHEN stock > 20 THEN 'Medio'
                    WHEN stock > 0 THEN 'Bajo'
                    ELSE 'Agotado'
                END) = 'Bajo' THEN 3
                ELSE 4
            END)
    ");
    
    $stockLevels = $stmt->fetchAll();
    
    // Top productos por valor
    $stmt = $pdo->query("
        SELECT name, stock, price, (price * stock) as total_value
        FROM products 
        ORDER BY total_value DESC 
        LIMIT 5
    ");
    
    $topProducts = $stmt->fetchAll();
    
    echo json_encode([
        'success' => true,
        'system' => APP_NAME,
        'timestamp' => date('Y-m-d H:i:s'),
        'stock_levels' => $stockLevels,
        'top_products_by_value' => $topProducts
    ]);
}

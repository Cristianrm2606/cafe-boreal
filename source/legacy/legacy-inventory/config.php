<?php
// Configuración de base de datos
define('DB_HOST', '127.0.0.1');
define('DB_PORT', '5432');
define('DB_NAME', 'cafeboreal');
define('DB_USER', 'postgres');
define('DB_PASS', 'postgres123');

// Configuración de la aplicación
define('APP_NAME', 'Inventario Legado - Café Boreal');
define('APP_VERSION', '1.0.0');

// Función para conectar a PostgreSQL
function getDBConnection() {
    try {
        $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_TIMEOUT => 5
        ]);
        return $pdo;
    } catch (PDOException $e) {
        error_log("Error de conexión DB: " . $e->getMessage());
        return null;
    }
}

// Headers para JSON
function setJSONHeaders() {
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
}
?>

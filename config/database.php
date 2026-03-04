<?php
// Database Connection Settings
define('DB_HOST', 'localhost');
define('DB_NAME', 'quickbite');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// PDO Options for Security and Performance
define('DB_OPTIONS', [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
]);

/**
 * Get Database Connection
 * Returns a PDO instance with configured settings
 * 
 * @return PDO
 * @throws PDOException
 */
function getDBConnection() {
    static $pdo = null;
    
    if ($pdo === null) {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
            $pdo = new PDO($dsn, DB_USER, DB_PASS, DB_OPTIONS);
        } catch (PDOException $e) {
            // Log error in production, display in development
            if (APP_ENV === 'development') {
                die("Database Connection Failed: " . $e->getMessage());
            } else {
                error_log("Database Connection Error: " . $e->getMessage());
                die("Database connection error. Please contact support.");
            }
        }
    }
    
    return $pdo;
}

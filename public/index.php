<?php
/**
 * QuickBite - Application Entry Point
 * All requests are routed through this file
 */

// Load Configuration Files
require_once __DIR__ . '/../config/app.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/payment.php';

// Autoload Core Classes
spl_autoload_register(function ($class) {
    $file = APP_PATH . '/' . str_replace('\\', '/', $class) . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

// Load Helper Functions
require_once APP_PATH . '/Helpers/functions.php';

// Get URL from query string
$url = isset($_GET['url']) ? rtrim($_GET['url'], '/') : 'home';
$url = filter_var($url, FILTER_SANITIZE_URL);
$url = explode('/', $url);

// Determine Controller and Method
$controllerName = !empty($url[0]) ? ucfirst($url[0]) . 'Controller' : 'HomeController';
$controllerFile = APP_PATH . '/Controllers/' . $controllerName . '.php';

// Check if controller exists
if (file_exists($controllerFile)) {
    require_once $controllerFile;
    $controller = new $controllerName();
    
    // Determine method
    $method = isset($url[1]) && !empty($url[1]) ? $url[1] : 'index';
    
    // Get parameters
    $params = array_slice($url, 2);
    
    // Call method if exists
    if (method_exists($controller, $method)) {
        call_user_func_array([$controller, $method], $params);
    } else {
        // Method not found
        http_response_code(404);
        require_once VIEW_PATH . '/errors/404.php';
    }
} else {
    // Controller not found
    http_response_code(404);
    require_once VIEW_PATH . '/errors/404.php';
}

<?php
/**
 * Application Configuration
 * QuickBite Multi-Vendor Food Delivery Platform
 */

// Application Settings
define('APP_NAME', 'QuickBite');
define('APP_URL', 'http://localhost/QuickBite');
define('APP_ENV', 'development'); // development, production
define('APP_DEBUG', true); // Set to false in production

// Timezone Configuration
define('TIMEZONE', 'Asia/Dhaka');
date_default_timezone_set(TIMEZONE);

// Directory Paths
define('ROOT_PATH', dirname(__DIR__));
define('APP_PATH', ROOT_PATH . '/app');
define('PUBLIC_PATH', ROOT_PATH . '/public');
define('UPLOAD_PATH', PUBLIC_PATH . '/uploads');
define('VIEW_PATH', APP_PATH . '/Views');

// URL Paths
define('BASE_URL', APP_URL);
define('ASSETS_URL', BASE_URL . '/public');
define('CSS_URL', ASSETS_URL . '/css');
define('JS_URL', ASSETS_URL . '/js');
define('UPLOAD_URL', ASSETS_URL . '/uploads');

// Session Configuration
define('SESSION_LIFETIME', 7200); // 2 hours in seconds
define('SESSION_NAME', 'quickbite_session');

// Security Settings
define('HASH_ALGO', PASSWORD_BCRYPT);
define('HASH_COST', 10);

// Pagination
define('ITEMS_PER_PAGE', 20);

// File Upload Settings
define('MAX_FILE_SIZE', 5242880); // 5MB in bytes
define('ALLOWED_IMAGE_TYPES', ['image/jpeg', 'image/png', 'image/jpg', 'image/gif']);
define('ALLOWED_IMAGE_EXTENSIONS', ['jpg', 'jpeg', 'png', 'gif']);

// Order Settings
define('DELIVERY_FEE', 50.00);
define('DEFAULT_COMMISSION_PERCENT', 15.00);
define('MIN_ORDER_AMOUNT', 100.00);

// Withdrawal Settings
define('MIN_WITHDRAWAL_AMOUNT', 500.00);
define('MAX_WITHDRAWAL_AMOUNT', 50000.00);

// Google Maps API (Get your key from: https://console.cloud.google.com/)
define('GOOGLE_MAPS_API_KEY', 'YOUR_GOOGLE_MAPS_API_KEY');

// Email Configuration (SMTP)
define('MAIL_HOST', 'smtp.gmail.com');
define('MAIL_PORT', 587);
define('MAIL_USERNAME', 'your_email@gmail.com');
define('MAIL_PASSWORD', 'your_app_password');
define('MAIL_FROM_EMAIL', 'noreply@quickbite.com');
define('MAIL_FROM_NAME', 'QuickBite');

// SMS Configuration (Optional)
define('SMS_ENABLED', false);
define('SMS_API_KEY', '');
define('SMS_SENDER_ID', 'QuickBite');

// Error Reporting
if (APP_ENV === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
    ini_set('log_errors', 1);
    ini_set('error_log', ROOT_PATH . '/logs/error.log');
}

// Start Session
if (session_status() === PHP_SESSION_NONE) {
    ini_set('session.cookie_httponly', 1);
    ini_set('session.use_only_cookies', 1);
    ini_set('session.cookie_secure', 0); // Set to 1 if using HTTPS
    session_name(SESSION_NAME);
    session_start();
}

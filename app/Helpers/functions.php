<?php
/**
 * Helper Functions
 * QuickBite - Utility functions used throughout the application
 */

/**
 * Redirect to a URL
 * 
 * @param string $url
 * @return void
 */
function redirect($url) {
    header("Location: " . BASE_URL . '/' . ltrim($url, '/'));
    exit;
}

/**
 * Check if user is logged in
 * 
 * @return bool
 */
function isLoggedIn() {
    return isset($_SESSION['user_id']);
}

/**
 * Get current user data
 * 
 * @return array|null
 */
function currentUser() {
    if (isLoggedIn()) {
        return [
            'id' => $_SESSION['user_id'],
            'name' => $_SESSION['user_name'] ?? '',
            'email' => $_SESSION['user_email'] ?? '',
            'role' => $_SESSION['user_role'] ?? ''
        ];
    }
    return null;
}

/**
 * Check if user has specific role
 * 
 * @param string $role
 * @return bool
 */
function hasRole($role) {
    return isLoggedIn() && $_SESSION['user_role'] === $role;
}

/**
 * Sanitize input data
 * 
 * @param string $data
 * @return string
 */
function sanitize($data) {
    return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
}

/**
 * Display success message
 * 
 * @param string $message
 * @return void
 */
function setSuccess($message) {
    $_SESSION['success'] = $message;
}

/**
 * Display error message
 * 
 * @param string $message
 * @return void
 */
function setError($message) {
    $_SESSION['error'] = $message;
}

/**
 * Get and clear success message
 * 
 * @return string|null
 */
function getSuccess() {
    if (isset($_SESSION['success'])) {
        $message = $_SESSION['success'];
        unset($_SESSION['success']);
        return $message;
    }
    return null;
}

/**
 * Get and clear error message
 * 
 * @return string|null
 */
function getError() {
    if (isset($_SESSION['error'])) {
        $message = $_SESSION['error'];
        unset($_SESSION['error']);
        return $message;
    }
    return null;
}

/**
 * Generate CSRF Token
 * 
 * @return string
 */
function generateCSRFToken() {
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Verify CSRF Token
 * 
 * @param string $token
 * @return bool
 */
function verifyCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Upload file
 * 
 * @param array $file
 * @param string $destination
 * @return string|false
 */
function uploadFile($file, $destination = 'products') {
    if (!isset($file['error']) || $file['error'] !== UPLOAD_ERR_OK) {
        return false;
    }
    
    if ($file['size'] > MAX_FILE_SIZE) {
        return false;
    }
    
    $fileType = mime_content_type($file['tmp_name']);
    if (!in_array($fileType, ALLOWED_IMAGE_TYPES)) {
        return false;
    }
    
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    if (!in_array(strtolower($extension), ALLOWED_IMAGE_EXTENSIONS)) {
        return false;
    }
    
    $fileName = uniqid() . '_' . time() . '.' . $extension;
    $uploadPath = UPLOAD_PATH . '/' . $destination . '/' . $fileName;
    
    if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
        return $fileName;
    }
    
    return false;
}

/**
 * Delete file
 * 
 * @param string $fileName
 * @param string $destination
 * @return bool
 */
function deleteFile($fileName, $destination = 'products') {
    $filePath = UPLOAD_PATH . '/' . $destination . '/' . $fileName;
    if (file_exists($filePath)) {
        return unlink($filePath);
    }
    return false;
}

/**
 * Format date
 * 
 * @param string $date
 * @param string $format
 * @return string
 */
function formatDate($date, $format = 'd M Y, h:i A') {
    return date($format, strtotime($date));
}

/**
 * Time ago
 * 
 * @param string $datetime
 * @return string
 */
function timeAgo($datetime) {
    $timestamp = strtotime($datetime);
    $difference = time() - $timestamp;
    
    if ($difference < 60) {
        return 'Just now';
    } elseif ($difference < 3600) {
        $minutes = floor($difference / 60);
        return $minutes . ' minute' . ($minutes > 1 ? 's' : '') . ' ago';
    } elseif ($difference < 86400) {
        $hours = floor($difference / 3600);
        return $hours . ' hour' . ($hours > 1 ? 's' : '') . ' ago';
    } elseif ($difference < 604800) {
        $days = floor($difference / 86400);
        return $days . ' day' . ($days > 1 ? 's' : '') . ' ago';
    } else {
        return date('d M Y', $timestamp);
    }
}

/**
 * Generate unique order number
 * 
 * @return string
 */
function generateOrderNumber() {
    return 'QB' . date('Ymd') . strtoupper(substr(uniqid(), -6));
}

/**
 * Calculate commission
 * 
 * @param float $amount
 * @param float $percent
 * @return float
 */
function calculateCommission($amount, $percent) {
    return round(($amount * $percent) / 100, 2);
}

/**
 * JSON Response
 * 
 * @param bool $success
 * @param string $message
 * @param mixed $data
 * @return void
 */
function jsonResponse($success, $message, $data = null) {
    header('Content-Type: application/json');
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);
    exit;
}

<?php
/**
 * Payment Gateway Configuration
 * QuickBite Multi-Vendor Food Delivery Platform
 */

// Payment Methods Enabled
define('PAYMENT_COD_ENABLED', true);
define('PAYMENT_BKASH_ENABLED', true);
define('PAYMENT_NAGAD_ENABLED', true);
define('PAYMENT_CARD_ENABLED', true);

// bKash Configuration
// Get credentials from: https://developer.bka.sh/
define('BKASH_APP_KEY', 'your_bkash_app_key');
define('BKASH_APP_SECRET', 'your_bkash_app_secret');
define('BKASH_USERNAME', 'your_bkash_username');
define('BKASH_PASSWORD', 'your_bkash_password');
define('BKASH_BASE_URL', 'https://tokenized.sandbox.bka.sh/v1.2.0-beta'); // Sandbox URL
// Production URL: https://tokenized.pay.bka.sh/v1.2.0-beta

// Nagad Configuration
// Get credentials from: https://nagad.com.bd/merchant/
define('NAGAD_MERCHANT_ID', 'your_nagad_merchant_id');
define('NAGAD_MERCHANT_NUMBER', 'your_nagad_merchant_number');
define('NAGAD_PUBLIC_KEY', 'your_nagad_public_key');
define('NAGAD_PRIVATE_KEY', 'your_nagad_private_key');
define('NAGAD_BASE_URL', 'http://sandbox.mynagad.com:10080/remote-payment-gateway-1.0/api/dfs'); // Sandbox URL
// Production URL: https://api.mynagad.com/api/dfs

// Card Payment Gateway (SSL Commerz)
// Get credentials from: https://sslcommerz.com/
define('SSLCZ_STORE_ID', 'your_store_id');
define('SSLCZ_STORE_PASSWORD', 'your_store_password');
define('SSLCZ_SANDBOX', true); // Set to false for production
define('SSLCZ_SUCCESS_URL', APP_URL . '/payment/success');
define('SSLCZ_FAIL_URL', APP_URL . '/payment/failed');
define('SSLCZ_CANCEL_URL', APP_URL . '/payment/cancel');
define('SSLCZ_IPN_URL', APP_URL . '/payment/ipn');

// Payment Gateway URLs
if (SSLCZ_SANDBOX) {
    define('SSLCZ_API_URL', 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php');
    define('SSLCZ_VALIDATION_URL', 'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php');
} else {
    define('SSLCZ_API_URL', 'https://securepay.sslcommerz.com/gwprocess/v4/api.php');
    define('SSLCZ_VALIDATION_URL', 'https://securepay.sslcommerz.com/validator/api/validationserverAPI.php');
}

// Payment Status
define('PAYMENT_STATUS_PENDING', 'pending');
define('PAYMENT_STATUS_COMPLETED', 'completed');
define('PAYMENT_STATUS_FAILED', 'failed');
define('PAYMENT_STATUS_REFUNDED', 'refunded');

// Transaction Settings
define('CURRENCY', 'BDT');
define('CURRENCY_SYMBOL', '৳');

/**
 * Get Available Payment Methods
 * 
 * @return array
 */
function getAvailablePaymentMethods() {
    $methods = [];
    
    if (PAYMENT_COD_ENABLED) {
        $methods['cod'] = [
            'name' => 'Cash on Delivery',
            'icon' => 'fa-money-bill',
            'description' => 'Pay with cash when you receive your order'
        ];
    }
    
    if (PAYMENT_BKASH_ENABLED) {
        $methods['bkash'] = [
            'name' => 'bKash',
            'icon' => 'fa-mobile-alt',
            'description' => 'Pay securely with bKash mobile wallet'
        ];
    }
    
    if (PAYMENT_NAGAD_ENABLED) {
        $methods['nagad'] = [
            'name' => 'Nagad',
            'icon' => 'fa-mobile-alt',
            'description' => 'Pay securely with Nagad mobile wallet'
        ];
    }
    
    if (PAYMENT_CARD_ENABLED) {
        $methods['card'] = [
            'name' => 'Credit/Debit Card',
            'icon' => 'fa-credit-card',
            'description' => 'Pay with Visa, MasterCard, or other cards'
        ];
    }
    
    return $methods;
}

/**
 * Format Currency
 * 
 * @param float $amount
 * @return string
 */
function formatCurrency($amount) {
    return CURRENCY_SYMBOL . ' ' . number_format($amount, 2);
}

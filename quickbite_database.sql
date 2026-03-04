-- =====================================================
-- QuickBite Multi-Vendor Food Delivery Platform
-- Database Schema - MySQL InnoDB
-- Version: 1.0
-- =====================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- Database Creation
CREATE DATABASE IF NOT EXISTS `quickbite` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `quickbite`;

-- =====================================================
-- Table: users
-- Purpose: Central user authentication and profile management
-- Supports: customers, vendors, delivery personnel, admins
-- =====================================================
CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('customer', 'vendor', 'delivery', 'admin', 'super_admin') NOT NULL DEFAULT 'customer',
  `profile_image` VARCHAR(255) DEFAULT NULL,
  `status` ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
  `email_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: vendors
-- Purpose: Store vendor/restaurant information
-- Relationship: One-to-One with users table
-- =====================================================
CREATE TABLE `vendors` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `store_name` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `logo` VARCHAR(255) DEFAULT NULL,
  `banner` VARCHAR(255) DEFAULT NULL,
  `address` TEXT NOT NULL,
  `latitude` DECIMAL(10, 8) DEFAULT NULL,
  `longitude` DECIMAL(11, 8) DEFAULT NULL,
  `commission_percent` DECIMAL(5, 2) NOT NULL DEFAULT 15.00,
  `is_open` TINYINT(1) NOT NULL DEFAULT 1,
  `status` ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_open` (`is_open`),
  KEY `idx_location` (`latitude`, `longitude`),
  CONSTRAINT `fk_vendors_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: categories
-- Purpose: Product categories for each vendor
-- Relationship: Many-to-One with vendors
-- =====================================================
CREATE TABLE `categories` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vendor_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_categories_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: products
-- Purpose: Food items/products offered by vendors
-- Relationship: Many-to-One with vendors and categories
-- =====================================================
CREATE TABLE `products` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vendor_id` BIGINT UNSIGNED NOT NULL,
  `category_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `discount_price` DECIMAL(10, 2) DEFAULT NULL,
  `image` VARCHAR(255) DEFAULT NULL,
  `is_available` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_is_available` (`is_available`),
  CONSTRAINT `fk_products_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: inventory
-- Purpose: Track product stock levels
-- Relationship: One-to-One with products
-- =====================================================
CREATE TABLE `inventory` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL DEFAULT 0,
  `low_stock_alert` INT NOT NULL DEFAULT 10,
  `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_id` (`product_id`),
  KEY `idx_quantity` (`quantity`),
  CONSTRAINT `fk_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: cart
-- Purpose: Temporary storage for customer shopping cart
-- Relationship: Many-to-One with users and products
-- =====================================================
CREATE TABLE `cart` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: orders
-- Purpose: Main order records with status tracking
-- Commission Formula: commission_amount = total_amount * commission_percent / 100
-- =====================================================
CREATE TABLE `orders` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_number` VARCHAR(50) NOT NULL,
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `vendor_id` BIGINT UNSIGNED NOT NULL,
  `delivery_id` BIGINT UNSIGNED DEFAULT NULL,
  `total_amount` DECIMAL(10, 2) NOT NULL,
  `commission_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `delivery_fee` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `payment_status` ENUM('pending', 'paid', 'failed') NOT NULL DEFAULT 'pending',
  `order_status` ENUM('pending', 'accepted', 'preparing', 'ready', 'picked', 'on_the_way', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  `delivery_address` TEXT NOT NULL,
  `latitude` DECIMAL(10, 8) DEFAULT NULL,
  `longitude` DECIMAL(11, 8) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_delivery_id` (`delivery_id`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_orders_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_orders_delivery` FOREIGN KEY (`delivery_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: order_items
-- Purpose: Individual items within each order
-- Relationship: Many-to-One with orders and products
-- =====================================================
CREATE TABLE `order_items` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: delivery_tracking
-- Purpose: Real-time GPS tracking for delivery personnel
-- Relationship: Many-to-One with orders and delivery users
-- =====================================================
CREATE TABLE `delivery_tracking` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `delivery_id` BIGINT UNSIGNED NOT NULL,
  `latitude` DECIMAL(10, 8) NOT NULL,
  `longitude` DECIMAL(11, 8) NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_delivery_id` (`delivery_id`),
  KEY `idx_updated_at` (`updated_at`),
  CONSTRAINT `fk_tracking_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tracking_delivery` FOREIGN KEY (`delivery_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: payments
-- Purpose: Payment transaction records
-- Relationship: One-to-One with orders
-- =====================================================
CREATE TABLE `payments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `payment_method` ENUM('cod', 'bkash', 'nagad', 'card') NOT NULL,
  `transaction_id` VARCHAR(255) DEFAULT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `status` ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payment_method` (`payment_method`),
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: reviews
-- Purpose: Customer reviews and ratings for products
-- Relationship: Many-to-One with users and products
-- =====================================================
CREATE TABLE `reviews` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `rating` TINYINT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
  `comment` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_rating` (`rating`),
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: vendor_wallet
-- Purpose: Track vendor earnings and balance
-- Relationship: One-to-One with vendors
-- =====================================================
CREATE TABLE `vendor_wallet` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vendor_id` BIGINT UNSIGNED NOT NULL,
  `total_earnings` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
  `total_withdrawn` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
  `balance` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_id` (`vendor_id`),
  CONSTRAINT `fk_wallet_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: withdrawals
-- Purpose: Vendor withdrawal requests and approval tracking
-- Relationship: Many-to-One with vendors
-- =====================================================
CREATE TABLE `withdrawals` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `vendor_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  `request_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approved_date` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_request_date` (`request_date`),
  CONSTRAINT `fk_withdrawals_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SEED DATA - Sample Records for Testing
-- =====================================================

-- Insert Users
INSERT INTO `users` (`id`, `name`, `email`, `phone`, `password`, `role`, `status`, `email_verified`) VALUES
(1, 'Super Admin', 'admin@quickbite.com', '+8801700000001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 'active', 1),
(2, 'John Doe', 'john@example.com', '+8801700000002', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer', 'active', 1),
(3, 'Pizza Palace Owner', 'pizza@vendor.com', '+8801700000003', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'vendor', 'active', 1),
(4, 'Burger Hub Owner', 'burger@vendor.com', '+8801700000004', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'vendor', 'active', 1),
(5, 'Delivery Person 1', 'delivery1@quickbite.com', '+8801700000005', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'delivery', 'active', 1),
(6, 'Sarah Smith', 'sarah@example.com', '+8801700000006', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer', 'active', 1);

-- Insert Vendors
INSERT INTO `vendors` (`id`, `user_id`, `store_name`, `description`, `address`, `latitude`, `longitude`, `commission_percent`, `is_open`, `status`) VALUES
(1, 3, 'Pizza Palace', 'Best pizzas in town with authentic Italian recipes', '123 Main Street, Dhaka', 23.8103, 90.4125, 15.00, 1, 'active'),
(2, 4, 'Burger Hub', 'Juicy burgers and crispy fries', '456 Park Avenue, Dhaka', 23.7805, 90.4258, 12.00, 1, 'active');

-- Insert Categories
INSERT INTO `categories` (`id`, `vendor_id`, `name`, `status`) VALUES
(1, 1, 'Pizzas', 'active'),
(2, 1, 'Sides', 'active'),
(3, 2, 'Burgers', 'active'),
(4, 2, 'Fries', 'active');

-- Insert Products
INSERT INTO `products` (`id`, `vendor_id`, `category_id`, `name`, `description`, `price`, `discount_price`, `is_available`) VALUES
(1, 1, 1, 'Margherita Pizza', 'Classic pizza with tomato sauce, mozzarella, and basil', 450.00, 400.00, 1),
(2, 1, 1, 'Pepperoni Pizza', 'Loaded with pepperoni and cheese', 550.00, NULL, 1),
(3, 1, 2, 'Garlic Bread', 'Crispy garlic bread with herbs', 150.00, NULL, 1),
(4, 2, 3, 'Classic Beef Burger', 'Juicy beef patty with fresh vegetables', 350.00, 320.00, 1),
(5, 2, 3, 'Chicken Burger', 'Grilled chicken with special sauce', 300.00, NULL, 1),
(6, 2, 4, 'French Fries', 'Crispy golden fries', 120.00, NULL, 1);

-- Insert Inventory
INSERT INTO `inventory` (`product_id`, `quantity`, `low_stock_alert`) VALUES
(1, 50, 10),
(2, 45, 10),
(3, 100, 20),
(4, 60, 15),
(5, 55, 15),
(6, 150, 30);

-- Insert Orders
INSERT INTO `orders` (`id`, `order_number`, `customer_id`, `vendor_id`, `delivery_id`, `total_amount`, `commission_amount`, `delivery_fee`, `payment_status`, `order_status`, `delivery_address`, `latitude`, `longitude`, `created_at`) VALUES
(1, 'QB20240001', 2, 1, 5, 550.00, 82.50, 50.00, 'paid', 'delivered', '789 Customer Street, Dhaka', 23.7925, 90.4078, NOW() - INTERVAL 2 DAY),
(2, 'QB20240002', 6, 2, 5, 470.00, 56.40, 50.00, 'paid', 'on_the_way', '321 Buyer Road, Dhaka', 23.8000, 90.4200, NOW() - INTERVAL 1 HOUR);

-- Insert Order Items
INSERT INTO `order_items` (`order_id`, `product_id`, `quantity`, `price`) VALUES
(1, 1, 1, 400.00),
(1, 3, 1, 150.00),
(2, 4, 1, 320.00),
(2, 6, 1, 120.00);

-- Insert Payments
INSERT INTO `payments` (`order_id`, `payment_method`, `transaction_id`, `amount`, `status`) VALUES
(1, 'bkash', 'BKH123456789', 550.00, 'completed'),
(2, 'cod', NULL, 470.00, 'pending');

-- Insert Delivery Tracking
INSERT INTO `delivery_tracking` (`order_id`, `delivery_id`, `latitude`, `longitude`) VALUES
(2, 5, 23.7950, 90.4150);

-- Insert Reviews
INSERT INTO `reviews` (`user_id`, `product_id`, `rating`, `comment`) VALUES
(2, 1, 5, 'Amazing pizza! Will order again.'),
(2, 3, 4, 'Good garlic bread, could be more crispy.');

-- Insert Vendor Wallets
INSERT INTO `vendor_wallet` (`vendor_id`, `total_earnings`, `total_withdrawn`, `balance`) VALUES
(1, 467.50, 0.00, 467.50),
(2, 413.60, 200.00, 213.60);

-- Insert Withdrawals
INSERT INTO `withdrawals` (`vendor_id`, `amount`, `status`, `request_date`, `approved_date`) VALUES
(2, 200.00, 'approved', NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 2 DAY);

COMMIT;

-- =====================================================
-- END OF QUICKBITE DATABASE SCHEMA
-- =====================================================

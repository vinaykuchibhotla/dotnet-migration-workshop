-- Product Catalog Database Schema
-- Compatible with AWS DMS for migration to Amazon RDS

USE ProductCatalog;

-- Drop table if exists
DROP TABLE IF EXISTS Products;

-- Create Products table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0,
    Supplier VARCHAR(255) NOT NULL,
    Description TEXT,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    INDEX idx_category (Category),
    INDEX idx_supplier (Supplier),
    INDEX idx_price (Price),
    INDEX idx_created_date (CreatedDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create audit table for DMS testing
CREATE TABLE ProductAudit (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    Action VARCHAR(10),
    OldValues JSON,
    NewValues JSON,
    ChangedBy VARCHAR(100),
    ChangedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_id (ProductID),
    INDEX idx_changed_date (ChangedDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

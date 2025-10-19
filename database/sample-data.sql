-- Sample data generation for Product Catalog
-- Generates 10,000+ product records for workshop

USE ProductCatalog;

-- Insert sample categories and suppliers
SET @categories = 'Electronics,Clothing,Books,Home & Garden,Sports,Toys,Automotive,Health & Beauty,Food & Beverage,Office Supplies';
SET @suppliers = 'TechCorp Inc,Fashion World,BookMart,GreenThumb Co,SportZone,ToyLand,AutoParts Plus,BeautyMax,FreshFoods,OfficeHub';

-- Generate 10,000 sample products using a stored procedure
DELIMITER //

CREATE PROCEDURE GenerateProducts()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE cat_count INT DEFAULT 10;
    DECLARE sup_count INT DEFAULT 10;
    DECLARE category_name VARCHAR(100);
    DECLARE supplier_name VARCHAR(255);
    DECLARE product_name VARCHAR(255);
    DECLARE price DECIMAL(10,2);
    DECLARE stock INT;
    
    WHILE i <= 10000 DO
        -- Random category
        SET category_name = CASE (i % cat_count) + 1
            WHEN 1 THEN 'Electronics'
            WHEN 2 THEN 'Clothing'
            WHEN 3 THEN 'Books'
            WHEN 4 THEN 'Home & Garden'
            WHEN 5 THEN 'Sports'
            WHEN 6 THEN 'Toys'
            WHEN 7 THEN 'Automotive'
            WHEN 8 THEN 'Health & Beauty'
            WHEN 9 THEN 'Food & Beverage'
            ELSE 'Office Supplies'
        END;
        
        -- Random supplier
        SET supplier_name = CASE (i % sup_count) + 1
            WHEN 1 THEN 'TechCorp Inc'
            WHEN 2 THEN 'Fashion World'
            WHEN 3 THEN 'BookMart'
            WHEN 4 THEN 'GreenThumb Co'
            WHEN 5 THEN 'SportZone'
            WHEN 6 THEN 'ToyLand'
            WHEN 7 THEN 'AutoParts Plus'
            WHEN 8 THEN 'BeautyMax'
            WHEN 9 THEN 'FreshFoods'
            ELSE 'OfficeHub'
        END;
        
        -- Generate product name
        SET product_name = CONCAT(category_name, ' Product ', LPAD(i, 5, '0'));
        
        -- Random price between 10 and 500
        SET price = ROUND(10 + (RAND() * 490), 2);
        
        -- Random stock between 0 and 1000
        SET stock = FLOOR(RAND() * 1001);
        
        INSERT INTO Products (ProductName, Category, Price, Stock, Supplier, Description, CreatedDate)
        VALUES (
            product_name,
            category_name,
            price,
            stock,
            supplier_name,
            CONCAT('High-quality ', category_name, ' product from ', supplier_name, '. Product ID: ', i),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
        );
        
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- Execute the procedure to generate data
CALL GenerateProducts();

-- Drop the procedure
DROP PROCEDURE GenerateProducts;

-- Insert some specific test records for demo purposes
INSERT INTO Products (ProductName, Category, Price, Stock, Supplier, Description) VALUES
('iPhone 14 Pro', 'Electronics', 999.99, 50, 'TechCorp Inc', 'Latest smartphone with advanced features'),
('Samsung Galaxy S23', 'Electronics', 899.99, 75, 'TechCorp Inc', 'Premium Android smartphone'),
('Nike Air Max', 'Sports', 129.99, 200, 'SportZone', 'Comfortable running shoes'),
('Levi\'s Jeans', 'Clothing', 79.99, 150, 'Fashion World', 'Classic denim jeans'),
('The Great Gatsby', 'Books', 12.99, 300, 'BookMart', 'Classic American literature');

-- Create some audit records for testing
INSERT INTO ProductAudit (ProductID, Action, NewValues, ChangedBy) 
SELECT ProductID, 'INSERT', JSON_OBJECT('ProductName', ProductName, 'Price', Price), 'SYSTEM'
FROM Products 
WHERE ProductID <= 10;

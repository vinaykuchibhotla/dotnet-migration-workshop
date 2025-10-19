#!/bin/bash
# Shell script to setup MySQL 8.0 on Amazon Linux 2
# For Legacy .NET Application Migration Workshop

set -e

MYSQL_ROOT_PASSWORD="WorkshopPassword123!"
MYSQL_APP_PASSWORD="AppPassword123!"
GITHUB_REPO="https://github.com/vinaykuchibhotla/dotnet-migration-workshop.git"

echo "Starting MySQL server setup..."

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install MySQL 8.0
echo "Installing MySQL 8.0..."
sudo yum install -y mysql-server git

# Start and enable MySQL service
echo "Starting MySQL service..."
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Get temporary root password if exists
TEMP_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log 2>/dev/null | tail -1 | awk '{print $NF}' || echo "")

# Configure MySQL root password
echo "Configuring MySQL root password..."
if [ ! -z "$TEMP_PASSWORD" ]; then
    # MySQL 8.0 with temporary password
    mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" 2>/dev/null || true
else
    # Fresh installation without password
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" 2>/dev/null || true
fi

# Wait a moment for MySQL to be ready
sleep 5

# Create database and user
echo "Creating database and application user..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS ProductCatalog;
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY '$MYSQL_APP_PASSWORD';
GRANT ALL PRIVILEGES ON ProductCatalog.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
EOF

# Configure MySQL for remote connections
echo "Configuring MySQL for remote connections..."
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf 2>/dev/null || true

# Add configuration if not exists
if ! grep -q "bind-address" /etc/my.cnf 2>/dev/null; then
    echo -e "\n[mysqld]\nbind-address = 0.0.0.0" | sudo tee -a /etc/my.cnf
fi

# Restart MySQL to apply configuration
echo "Restarting MySQL service..."
sudo systemctl restart mysqld

# Clone repository and load sample data
echo "Cloning repository and loading sample data..."
cd /tmp
git clone $GITHUB_REPO workshop-repo

# Load database schema and sample data
echo "Loading database schema..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" ProductCatalog < workshop-repo/database/schema.sql

echo "Loading sample data (this may take a few minutes)..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" ProductCatalog < workshop-repo/database/sample-data.sql

# Verify data load
RECORD_COUNT=$(mysql -u root -p"$MYSQL_ROOT_PASSWORD" -se "SELECT COUNT(*) FROM ProductCatalog.Products;")
echo "Database setup completed. Total products loaded: $RECORD_COUNT"

# Configure firewall (if firewalld is running)
if systemctl is-active --quiet firewalld; then
    echo "Configuring firewall..."
    sudo firewall-cmd --permanent --add-port=3306/tcp
    sudo firewall-cmd --reload
fi

# Display connection information
echo "============================================"
echo "MySQL Setup Completed Successfully!"
echo "============================================"
echo "Database: ProductCatalog"
echo "Application User: appuser"
echo "Application Password: $MYSQL_APP_PASSWORD"
echo "Root Password: $MYSQL_ROOT_PASSWORD"
echo "Total Products: $RECORD_COUNT"
echo "============================================"
echo "MySQL is ready for .NET application connection"

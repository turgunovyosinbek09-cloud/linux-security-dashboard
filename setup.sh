#!/bin/bash
# ============================================
# Linux Security Dashboard - Setup Script
# Author: Yosin Turgunov
# GitHub: turgunovyosinbek09-cloud
# ============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "============================================"
echo "   Linux Security Dashboard - Setup"
echo "   github.com/turgunovyosinbek09-cloud"
echo "============================================"
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run with sudo${NC}"
    echo "Usage: sudo ./setup.sh"
    exit 1
fi

echo -e "${YELLOW}[1/6] Updating package list...${NC}"
apt update -q
echo -e "${GREEN}Done.${NC}"

echo -e "${YELLOW}[2/6] Installing Apache, MySQL, SSH...${NC}"
apt install -y apache2 mariadb-server openssh-server 2>/dev/null
echo -e "${GREEN}Done.${NC}"

echo -e "${YELLOW}[3/6] Starting services...${NC}"
service apache2 start
service mysql start
service ssh start
service rsyslog start
echo -e "${GREEN}Done.${NC}"

echo -e "${YELLOW}[4/6] Setting up MySQL database...${NC}"
mysql -u root << 'SQLEOF'
CREATE DATABASE IF NOT EXISTS security_dashboard;
USE security_dashboard;
CREATE TABLE IF NOT EXISTS system_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    logged_at DATETIME,
    disk_usage VARCHAR(10),
    memory_used VARCHAR(20),
    failed_logins INT,
    apache_status VARCHAR(10),
    mysql_status VARCHAR(10),
    ssh_status VARCHAR(10)
);
GRANT ALL PRIVILEGES ON security_dashboard.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
SQLEOF
echo -e "${GREEN}Done.${NC}"

echo -e "${YELLOW}[5/6] Deploying dashboard files...${NC}"
# Copy scripts
chmod 755 scripts/generate_dashboard.sh
chmod 755 scripts/healthcheck.sh
chmod 755 scripts/useraudit.sh

# Generate first dashboard
bash scripts/generate_dashboard.sh

echo -e "${GREEN}Done.${NC}"

echo -e "${YELLOW}[6/6] Setting up cron job...${NC}"
# Add cron job if it doesn't already exist
CRON_JOB="* * * * * /bin/bash $(pwd)/scripts/generate_dashboard.sh"
(crontab -l 2>/dev/null | grep -v "generate_dashboard"; echo "$CRON_JOB") | crontab -
echo -e "${GREEN}Done.${NC}"

echo ""
echo -e "${GREEN}============================================"
echo "   Setup Complete!"
echo -e "============================================${NC}"
echo ""
echo -e "Dashboard URL:  ${BLUE}http://localhost${NC}"
echo -e "GitHub:         ${BLUE}https://github.com/turgunovyosinbek09-cloud/linux-security-dashboard${NC}"
echo ""
echo "Services running:"
service apache2 status | grep "Active:" | awk '{print "  Apache:  " $2 " " $3}'
service mysql status | grep "Active:" | awk '{print "  MySQL:   " $2 " " $3}'
service ssh status | grep "Active:" | awk '{print "  SSH:     " $2 " " $3}'
echo ""
echo -e "${YELLOW}Dashboard auto-refreshes every 60 seconds.${NC}"
echo -e "${YELLOW}Cron job runs generate_dashboard.sh every minute.${NC}"

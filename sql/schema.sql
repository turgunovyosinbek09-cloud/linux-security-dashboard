-- Linux Security Dashboard
-- Database Schema
-- Author: Yosin Turgunov

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

# 🛡️ Linux Security Dashboard

![Apache](https://img.shields.io/badge/Apache-2.4-red)
![MySQL](https://img.shields.io/badge/MySQL-MariaDB-blue)
![Bash](https://img.shields.io/badge/Bash-Scripting-green)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange)

A locally hosted security monitoring dashboard built with
Apache, MySQL, and Bash scripting on Ubuntu Linux.
Displays live system health, user audit data, service status,
and a MySQL-backed activity log. Auto-refreshes every 60 seconds.

## 📸 Preview
*(Add a screenshot here)*

## ✨ Features
- 🖥️ Live system info (hostname, OS, IP, uptime)
- ❤️ System health monitoring (disk, memory, swap, top process)
- 👤 User audit (login users, sudo members, root status)
- 🛡️ Service status (Apache, MySQL, SSH, logging)
- 📊 MySQL-backed activity log (last 5 snapshots)
- ⏱️ Auto-refreshes every 60 seconds via meta refresh
- 🔄 Cron job regenerates dashboard every minute with live data

## 🗂️ Project Structure
linux-security-dashboard/
├── setup.sh # One-command installer
├── README.md
├── scripts/
│ ├── generate_dashboard.sh # Main script, generates HTML + logs to MySQL
│ ├── healthcheck.sh # System health report
│ └── useraudit.sh # User and privilege audit
├── dashboard/
│ └── index.html # Static Stage 1 template
└── sql/
└── schema.sql # Database schema

## 🚀 Setup
```bash
git clone https://github.com/turgunovyosinbek09-cloud/linux-security-dashboard
cd linux-security-dashboard
chmod +x setup.sh
sudo ./setup.sh
```
Then open your browser to `http://localhost`

## 🗄️ Database Schema
```sql
CREATE TABLE system_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    logged_at DATETIME,
    disk_usage VARCHAR(10),
    memory_used VARCHAR(20),
    failed_logins INT,
    apache_status VARCHAR(10),
    mysql_status VARCHAR(10),
    ssh_status VARCHAR(10)
);
```

## 🛠️ Stack
- **Web Server:** Apache2
- **Database:** MariaDB/MySQL
- **Backend:** Bash scripting
- **Frontend:** HTML/CSS
- **OS:** Ubuntu 24.04 LTS

## 👤 Author
**Yosin Turgunov**
- GitHub: [@turgunovyosinbek09-cloud](https://github.com/turgunovyosinbek09-cloud)
- Goal: AWS Cloud Security Engineer

## 📄 License
MIT

#!/bin/bash
# ============================================
# Linux Security Dashboard - Data Generator
# Collects live system data and builds HTML
# ============================================

OUTPUT=/var/www/html/index.html

# ---- Collect live data ----
HOSTNAME=$(hostname)
IP=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
DATE=$(date '+%Y-%m-%d %H:%M:%S')
OS=$(lsb_release -d | cut -f2)
UPTIME=$(uptime -p)
DISK=$(df -h / | awk 'NR==2 {print $5}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
MEM_USED=$(free -h | awk 'NR==2 {print $3}')
MEM_TOTAL=$(free -h | awk 'NR==2 {print $2}')
SWAP_USED=$(free -h | awk 'NR==3 {print $3}')
SWAP_TOTAL=$(free -h | awk 'NR==3 {print $2}')
TOP_PROC=$(ps aux --sort=-%cpu | awk 'NR==2 {print $11}' | xargs basename)
TOP_CPU=$(ps aux --sort=-%cpu | awk 'NR==2 {print $3}')
LOGIN_USERS=$(grep -E "/bin/bash|/bin/zsh" /etc/passwd | cut -d: -f1 | tr '\n' ', ' | sed 's/,$//')
SUDO_MEMBERS=$(grep "^sudo" /etc/group | cut -d: -f4)
FAILED_LOGINS=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null | head -1 || echo "0")

# Check root account status
if sudo grep -q "^root:!" /etc/shadow 2>/dev/null || sudo grep -q "^root:\*" /etc/shadow 2>/dev/null; then
    ROOT_STATUS="Locked"
    ROOT_COLOR="#3fb950"
else
    ROOT_STATUS="Has Password"
    ROOT_COLOR="#d29922"
fi

# Check services
check_service() {
    if systemctl is-active --quiet $1 2>/dev/null || service $1 status >/dev/null 2>&1; then
        echo "&#x2713; Running"
    else
        echo "&#x2717; Stopped"
    fi
}

check_service_color() {
    if systemctl is-active --quiet $1 2>/dev/null || service $1 status >/dev/null 2>&1; then
        echo "#3fb950"
    else
        echo "#f85149"
    fi
}

APACHE_STATUS=$(check_service apache2)
APACHE_COLOR=$(check_service_color apache2)
MYSQL_STATUS=$(check_service mysql)
MYSQL_COLOR=$(check_service_color mysql)
SSH_STATUS=$(check_service ssh)
SSH_COLOR=$(check_service_color ssh)
RSYSLOG_STATUS=$(check_service rsyslog)
RSYSLOG_COLOR=$(check_service_color rsyslog)

# Disk color based on usage
DISK_NUM=$(echo $DISK | tr -d '%')
if [ "$DISK_NUM" -lt 60 ]; then
    DISK_COLOR="#3fb950"
elif [ "$DISK_NUM" -lt 80 ]; then
    DISK_COLOR="#d29922"
else
    DISK_COLOR="#f85149"
fi

# Failed logins color
FAILED_NUM=$(echo "$FAILED_LOGINS" | grep -o '[0-9]*' | head -1)
FAILED_NUM=${FAILED_NUM:-0}
if [ "$FAILED_NUM" -eq 0 ]; then
    FAILED_COLOR="#3fb950"
elif [ "$FAILED_NUM" -lt 10 ]; then
    FAILED_COLOR="#d29922"
else
    FAILED_COLOR="#f85149"
fi
FAILED_LOGINS=$FAILED_NUM

# ---- Generate HTML ----
sudo tee $OUTPUT > /dev/null << HTML
<!DOCTYPE html><html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="60">
    <title>Linux Security Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background-color: #0d1117;
            color: #c9d1d9;
            font-family: 'Courier New', monospace;
            padding: 20px;
        }
        header {
            text-align: center;
            padding: 30px;
            border-bottom: 1px solid #30363d;
            margin-bottom: 30px;
        }
        header h1 { color: #58a6ff; font-size: 2em; margin-bottom: 10px; }
        header p { color: #8b949e; font-size: 0.9em; }
        .updated {
            display: inline-block;
            margin-top: 10px;
            padding: 4px 12px;
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 20px;
            font-size: 0.75em;
            color: #3fb950;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        .card {
            background-color: #161b22;
            border: 1px solid #30363d;
            border-radius: 8px;
            padding: 20px;
        }
        .card h2 {
            color: #58a6ff;
            font-size: 1em;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #30363d;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #21262d;
            font-size: 0.9em;
        }
        .info-row:last-child { border-bottom: none; }
        .info-row .key { color: #8b949e; }
        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.75em;
            background-color: #1f6feb;
            color: white;
        }
        footer {
            text-align: center;
            margin-top: 40px;
            padding: 20px;
            color: #8b949e;
            font-size: 0.8em;
            border-top: 1px solid #30363d;
        }
    </style>
</head>
<body>

<header>
    <h1>&#x1F6E1; Linux Security Dashboard</h1>
    <p>System monitoring and security audit tool | Ubuntu Linux</p>
    <p style="margin-top:8px; font-size:0.8em;">
        Built with Apache &bull; MySQL &bull; Bash Scripting
    </p>
    <span class="updated">&#x1F504; Last updated: $DATE</span>
</header>

<div class="grid">

    <div class="card">
        <h2>&#x1F4BB; System Info</h2>
        <div class="info-row">
            <span class="key">Hostname</span>
            <span>$HOSTNAME</span>
        </div>
        <div class="info-row">
            <span class="key">OS</span>
            <span>$OS</span>
        </div>
        <div class="info-row">
            <span class="key">IP Address</span>
            <span>$IP</span>
        </div>
        <div class="info-row">
            <span class="key">Uptime</span>
            <span>$UPTIME</span>
        </div>
        <div class="info-row">
            <span class="key">Web Server</span>
            <span>Apache2</span>
        </div>
    </div>

    <div class="card">
        <h2>&#x2764; System Health</h2>
        <div class="info-row">
            <span class="key">Disk Usage</span>
            <span style="color:$DISK_COLOR">$DISK ($DISK_USED / $DISK_TOTAL)</span>
        </div>
        <div class="info-row">
            <span class="key">Memory</span>
            <span style="color:#3fb950">$MEM_USED / $MEM_TOTAL</span>
        </div>
        <div class="info-row">
            <span class="key">Swap</span>
            <span style="color:#3fb950">$SWAP_USED / $SWAP_TOTAL</span>
        </div>
        <div class="info-row">
            <span class="key">Top Process</span>
            <span>$TOP_PROC ($TOP_CPU%)</span>
        </div>
        <div class="info-row">
            <span class="key">Uptime</span>
            <span>$UPTIME</span>
        </div>
    </div>

    <div class="card">
        <h2>&#x1F464; User Audit</h2>
        <div class="info-row">
            <span class="key">Login Users</span>
            <span>$LOGIN_USERS</span>
        </div>
        <div class="info-row">
            <span class="key">Sudo Members</span>
            <span style="color:#d29922">$SUDO_MEMBERS</span>
        </div>
        <div class="info-row">
            <span class="key">Root Account</span>
            <span style="color:$ROOT_COLOR">$ROOT_STATUS</span>
        </div>
        <div class="info-row">
            <span class="key">Failed Logins</span>
            <span style="color:$FAILED_COLOR">$FAILED_LOGINS</span>
        </div>
    </div>

    <div class="card">
        <h2>&#x1F6E1; Security Status</h2>
        <div class="info-row">
            <span class="key">Apache</span>
            <span style="color:$APACHE_COLOR">$APACHE_STATUS</span>
        </div>
        <div class="info-row">
            <span class="key">MySQL</span>
            <span style="color:$MYSQL_COLOR">$MYSQL_STATUS</span>
        </div>
        <div class="info-row">
            <span class="key">SSH</span>
            <span style="color:$SSH_COLOR">$SSH_STATUS</span>
        </div>
        <div class="info-row">
            <span class="key">Logging</span>
            <span style="color:$RSYSLOG_COLOR">$RSYSLOG_STATUS</span>
        </div>
    </div>

    <div class="card">
        <h2>&#x1F4DD; Scripts</h2>
        <div class="info-row">
            <span class="key">healthcheck.sh</span>
            <span class="badge">active</span>
        </div>
        <div class="info-row">
            <span class="key">useraudit.sh</span>
            <span class="badge">active</span>
        </div>
        <div class="info-row">
            <span class="key">generate_dashboard.sh</span>
            <span class="badge">active</span>
        </div>
        <div class="info-row">
            <span class="key">logmonitor.sh</span>
            <span class="badge">active</span>
        </div>
    </div>

    <div class="card">
        <h2>&#x1F4CA; Project Info</h2>
        <div class="info-row">
            <span class="key">Author</span>
            <span>Yosin Turgunov</span>
        </div>
        <div class="info-row">
            <span class="key">GitHub</span>
            <span>turgunovyosinbek09-cloud</span>
        </div>
        <div class="info-row">
            <span class="key">Goal</span>
            <span>AWS Cloud Security</span>
        </div>
        <div class="info-row">
            <span class="key">Stack</span>
            <span>Apache, MySQL, Bash</span>
        </div>
    </div>

</div>

<footer>
    <p>Linux Security Dashboard &bull; Built by Yosin Turgunov</p>
    <p style="margin-top:5px;">
        github.com/turgunovyosinbek09-cloud/linux-security-dashboard
    </p>
    <p style="margin-top:5px; font-size:0.75em;">
        Auto-refreshes every 60 seconds
    </p>
</footer>

</body>
</html>
HTML

echo "Dashboard generated at $DATE"

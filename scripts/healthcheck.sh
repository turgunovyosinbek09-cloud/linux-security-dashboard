#!/bin/bash
OUTPUT=~/healthreport.txt

echo "========= SYSTEM HEALTH REPORT ==========" > $OUTPUT
echo "Date: $(date)" >> $OUTPUT
echo "User: $(whoami)" >> $OUTPUT
echo "Hostname: $(hostname)" >> $OUTPUT
echo "" >> $OUTPUT

echo "=========== DISK USAGE REPORT ==========" >> $OUTPUT
df -h >> $OUTPUT
echo "" >> $OUTPUT

echo "============= MEMORY USAGE REPORT ========" >> $OUTPUT
free -h >> $OUTPUT
echo "" >> $OUTPUT

echo "========= UPTIME ========" >> $OUTPUT
uptime >> $OUTPUT
echo "" >> $OUTPUT

echo "======= IP ADDRESS ======" >> $OUTPUT
ip addr show eth0 | grep 'inet' >> $OUTPUT
echo "" >> $OUTPUT

echo "========== TOP 5 CPU PROCESSES ==========" >> $OUTPUT
ps aux --sort=-%cpu | head -6 >> $OUTPUT
echo "==========================================" >> $OUTPUT

cat $OUTPUT




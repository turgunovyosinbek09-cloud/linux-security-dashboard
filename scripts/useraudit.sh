#!/bin/bash
OUTPUT=~/useraudit.txt

echo "========= USER AUDIT REPORT ========" > $OUTPUT
echo "Date: $(date)" >> $OUTPUT
echo "Hostname: $(hostname)" >> $OUTPUT
echo "" >> $OUTPUT

echo "======= USERS WITH LOGIN SHELL =======" >> $OUTPUT
grep -E "/bin/bash|/bin/zsh" /etc/passwd >> $OUTPUT
echo "" >> $OUTPUT

echo "====== SUDO GROUP MEMBERS ======" >> $OUTPUT
grep "^sudo" /etc/group >> $OUTPUT
echo "" >> $OUTPUT

echo "====== LAST 5 LOGIN ATTEMPTS =======" >> $OUTPUT
last | head -5 >> $OUTPUT
echo "" >> $OUTPUT

echo "====== FAILED LOGIN ATTEMPTS ======" >> $OUTPUT
if [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | tail -5 >> $OUTPUT
else
    echo "auth.log not found on this system" >> $OUTPUT
fi
echo "" >> $OUTPUT

echo "====== ROOT ACCOUNT STATUS =======" >> $OUTPUT
if grep -q "^root:!" /etc/shadow 2>/dev/null || grep -q "^root:\*" /etc/shadow 2>/dev/null; then
    echo "ROOT: No password set (locked)" >> $OUTPUT
else
   echo "ROOT: Password is set" >> $OUTPUT
fi
echo "" >> $OUTPUT


cat $OUTPUT



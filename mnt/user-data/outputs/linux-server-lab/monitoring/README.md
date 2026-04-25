# 📊 Monitoring

---

## System Resources

```bash
# Install tools
sudo apt install htop nethogs iftop nload -y

# Interactive process viewer
htop

# Disk usage
df -h
du -sh /var/log/*

# Memory
free -h

# CPU info
lscpu
top -b -n1 | head -20
```

---

## Network Monitoring

```bash
# Traffic per process
sudo nethogs

# Interface traffic
sudo iftop -i eth0

# Bandwidth by interface
nload

# Active connections
ss -tulnp
netstat -an | grep ESTABLISHED

# Who is connected to your server right now
ss -tnp | grep ESTABLISHED
```

---

## Log Analysis

```bash
# Auth logs — SSH logins, sudo, failures
tail -f /var/log/auth.log
grep "Accepted" /var/log/auth.log        # Successful logins
grep "Failed" /var/log/auth.log          # Failed attempts
grep "sudo" /var/log/auth.log            # Sudo usage

# System logs
journalctl -f                            # Live
journalctl -u ssh -n 50                  # Last 50 SSH logs
journalctl --since "1 hour ago"

# Kernel logs
dmesg | tail -20
```

---

## Intrusion Detection

```bash
# Install rkhunter (rootkit hunter)
sudo apt install rkhunter -y
sudo rkhunter --update
sudo rkhunter --check

# Install chkrootkit
sudo apt install chkrootkit -y
sudo chkrootkit

# File integrity — check if system files changed
sudo apt install aide -y
sudo aideinit
sudo aide --check
```

---

## Automated Monitoring Script

```bash
#!/bin/bash
# Save as: monitor.sh

echo "=== $(date) ==="
echo ""
echo "--- CPU Usage ---"
top -b -n1 | grep "Cpu(s)"

echo ""
echo "--- Memory ---"
free -h

echo ""
echo "--- Disk ---"
df -h /

echo ""
echo "--- Active Connections ---"
ss -tn | grep ESTABLISHED | wc -l
echo "connections established"

echo ""
echo "--- Recent SSH Logins ---"
last | head -5

echo ""
echo "--- Failed Login Attempts (last 10) ---"
grep "Failed password" /var/log/auth.log | tail -10
```

```bash
chmod +x monitor.sh
# Run every hour via cron
crontab -e
# Add: 0 * * * * /home/user/monitor.sh >> /var/log/monitor.log 2>&1
```

---

## Useful One-Liners

```bash
# Top 10 IPs hitting your server
grep "Failed" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -10

# See what ports are open
sudo nmap -sV localhost

# Check running services
systemctl list-units --type=service --state=running

# Find large files
find / -type f -size +100M 2>/dev/null

# Watch a command in real time
watch -n 2 'ss -tulnp'
```

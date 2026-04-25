# 🔥 Firewall — UFW + Fail2ban

---

## UFW (Uncomplicated Firewall)

### Basic Setup

```bash
# Install
sudo apt install ufw -y

# Default policy — deny all incoming, allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow services
sudo ufw allow 2222/tcp      # SSH (your custom port)
sudo ufw allow 80/tcp        # HTTP
sudo ufw allow 443/tcp       # HTTPS
sudo ufw allow 53            # DNS (if running DNS server)

# Enable
sudo ufw enable

# Check status
sudo ufw status verbose
```

### Allow Specific IP Only (for SSH)

```bash
# Allow SSH only from your IP
sudo ufw allow from 192.168.1.100 to any port 2222

# Delete a rule
sudo ufw delete allow 22/tcp
```

### UFW Logging

```bash
sudo ufw logging on
sudo tail -f /var/log/ufw.log
```

---

## Fail2ban — Brute Force Protection

### Install & Configure

```bash
sudo apt install fail2ban -y

# Create local config (don't edit jail.conf directly)
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

### Recommended jail.local Settings

```ini
[DEFAULT]
bantime  = 1h          # Ban for 1 hour
findtime  = 10m        # Within 10 minutes
maxretry = 3           # 3 failed attempts = ban
banaction = ufw        # Use UFW to ban

[sshd]
enabled = true
port    = 2222         # Your SSH port
logpath = /var/log/auth.log
maxretry = 3
```

### Fail2ban Commands

```bash
# Start & enable
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# See banned IPs
sudo fail2ban-client status sshd | grep "Banned IP"

# Unban an IP
sudo fail2ban-client set sshd unbanip 1.2.3.4

# Check logs
sudo tail -f /var/log/fail2ban.log
```

---

## Check Open Ports

```bash
# All listening ports
sudo ss -tulnp

# With process names
sudo netstat -tulnp

# Scan yourself with nmap
nmap -sV localhost
```

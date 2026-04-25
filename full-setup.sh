#!/bin/bash
# ============================================================
#   linux-server-lab — Full Hardening Setup Script
#   Run as root: sudo bash scripts/full-setup.sh
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "\n${BLUE}[*] $1${NC}"; }
print_ok()   { echo -e "${GREEN}[+] $1${NC}"; }
print_warn() { echo -e "${YELLOW}[!] $1${NC}"; }
print_err()  { echo -e "${RED}[-] $1${NC}"; }

# Check root
if [ "$EUID" -ne 0 ]; then
    print_err "Please run as root: sudo bash $0"
    exit 1
fi

echo -e "${BLUE}"
echo "  ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗"
echo "  ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝"
echo "  ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ "
echo "  ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ "
echo "  ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗"
echo "  ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝"
echo "  Linux Server Lab — Hardening Script"
echo -e "${NC}"

# ─────────────────────────────────────────
print_step "Step 1: System Update"
# ─────────────────────────────────────────
apt update && apt upgrade -y
print_ok "System updated"

# ─────────────────────────────────────────
print_step "Step 2: Install Essential Packages"
# ─────────────────────────────────────────
apt install -y \
    ufw fail2ban \
    htop nethogs iftop \
    net-tools curl wget \
    git vim \
    rkhunter chkrootkit \
    bind9utils \
    unattended-upgrades
print_ok "Packages installed"

# ─────────────────────────────────────────
print_step "Step 3: Firewall Setup (UFW)"
# ─────────────────────────────────────────
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp    # SSH custom port
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable
print_ok "UFW configured and enabled"

# ─────────────────────────────────────────
print_step "Step 4: SSH Hardening"
# ─────────────────────────────────────────
SSH_CONFIG="/etc/ssh/sshd_config"
cp $SSH_CONFIG "${SSH_CONFIG}.bak"

sed -i 's/^#Port 22/Port 2222/' $SSH_CONFIG
sed -i 's/^Port 22/Port 2222/' $SSH_CONFIG
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' $SSH_CONFIG
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
sed -i 's/^#MaxAuthTries.*/MaxAuthTries 3/' $SSH_CONFIG
sed -i 's/^X11Forwarding yes/X11Forwarding no/' $SSH_CONFIG

print_warn "SSH config updated. Port changed to 2222."
print_warn "Enable key auth manually after adding your public key!"

systemctl restart ssh
print_ok "SSH restarted"

# ─────────────────────────────────────────
print_step "Step 5: Fail2ban Setup"
# ─────────────────────────────────────────
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 3
banaction = ufw

[sshd]
enabled  = true
port     = 2222
logpath  = /var/log/auth.log
maxretry = 3
EOF

systemctl enable fail2ban
systemctl restart fail2ban
print_ok "Fail2ban configured"

# ─────────────────────────────────────────
print_step "Step 6: Auto Security Updates"
# ─────────────────────────────────────────
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
print_ok "Automatic security updates enabled"

# ─────────────────────────────────────────
print_step "Step 7: System Hardening (sysctl)"
# ─────────────────────────────────────────
cat >> /etc/sysctl.conf << 'EOF'

# Security hardening
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
kernel.randomize_va_space = 2
EOF

sysctl -p > /dev/null 2>&1
print_ok "Kernel security parameters applied"

# ─────────────────────────────────────────
print_step "Step 8: Setup Monitoring Cron"
# ─────────────────────────────────────────
cat > /usr/local/bin/server-monitor.sh << 'MONITOR'
#!/bin/bash
LOG="/var/log/server-monitor.log"
echo "=== $(date) ===" >> $LOG
echo "--- Active Connections ---" >> $LOG
ss -tn | grep ESTABLISHED | wc -l >> $LOG
echo "--- Failed SSH Attempts ---" >> $LOG
grep "Failed password" /var/log/auth.log | tail -5 >> $LOG
echo "" >> $LOG
MONITOR

chmod +x /usr/local/bin/server-monitor.sh
(crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/server-monitor.sh") | crontab -
print_ok "Monitoring cron set up"

# ─────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ Setup Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  SSH Port:     ${YELLOW}2222${NC}"
echo -e "  Firewall:     ${GREEN}UFW enabled${NC}"
echo -e "  Fail2ban:     ${GREEN}Active${NC}"
echo -e "  Auto updates: ${GREEN}Enabled${NC}"
echo ""
print_warn "IMPORTANT: Add your SSH public key before disabling password auth!"
print_warn "Test SSH on port 2222 before closing this session!"
echo ""

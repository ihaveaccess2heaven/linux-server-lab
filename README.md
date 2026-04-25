# 🛡️ Linux Server Lab

> A hands-on learning repository for Ubuntu Server hardening, administration, and security. Built as a personal homelab reference and cybersecurity portfolio.

![Ubuntu](https://img.shields.io/badge/Ubuntu-Server_22.04-E95420?style=for-the-badge&logo=ubuntu)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)

---

## 📁 Repository Structure

```
linux-server-lab/
├── ssh/                  # SSH hardening & key management
├── firewall/             # UFW rules & Fail2ban config
├── dns/                  # BIND9 DNS server setup
├── users/                # User management & permissions
├── monitoring/           # System & network monitoring
├── ssl/                  # SSL/TLS certificates
└── scripts/              # Automation scripts
```

---

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/yourusername/linux-server-lab.git
cd linux-server-lab

# Run full hardening script (run as root)
chmod +x scripts/full-setup.sh
sudo bash scripts/full-setup.sh
```

---

## 📚 Topics Covered

| Topic | Description | Folder |
|---|---|---|
| 🔐 SSH Hardening | Key auth, port change, root lockout | `ssh/` |
| 🔥 Firewall | UFW rules, Fail2ban brute-force protection | `firewall/` |
| 🌐 DNS Server | BIND9 local DNS setup | `dns/` |
| 👥 Users | Creating users, sudo, permissions | `users/` |
| 📊 Monitoring | htop, nethogs, log analysis | `monitoring/` |
| 🔒 SSL/TLS | Let's Encrypt, self-signed certs | `ssl/` |

---

## ⚠️ Disclaimer

This repository is for **educational purposes only**. Use in your own lab/VM environment. Do not run on production systems without understanding each step.

---

*Built for learning. Red Team | Blue Team | Sysadmin*

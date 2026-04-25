# 🔐 SSH Hardening

Securing SSH is the **first and most critical** step in server hardening.

---

## Step 1 — Generate SSH Key Pair (on your local machine)

```bash
# Generate a strong Ed25519 key
ssh-keygen -t ed25519 -C "your-label"

# Copy public key to server
ssh-copy-id -p 22 user@server-ip
```

---

## Step 2 — Harden sshd_config

Edit the SSH daemon config:

```bash
sudo nano /etc/ssh/sshd_config
```

Apply these settings:

```
# === PORT ===
Port 2222                        # Change from default 22

# === AUTH ===
PermitRootLogin no               # Never allow root login
PasswordAuthentication no        # Keys only, no passwords
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# === LIMITS ===
MaxAuthTries 3                   # Lock after 3 failed attempts
MaxSessions 3
LoginGraceTime 30                # 30 seconds to authenticate

# === OTHER ===
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
```

---

## Step 3 — Restart SSH

```bash
sudo systemctl restart ssh
sudo systemctl status ssh
```

> ⚠️ **Important:** Open a second terminal and test login BEFORE closing current session.

```bash
ssh -p 2222 user@server-ip
```

---

## Step 4 — Allow New Port in Firewall

```bash
sudo ufw allow 2222/tcp
sudo ufw deny 22/tcp
```

---

## Useful SSH Commands

```bash
# See active SSH sessions
who
w
last | grep ssh

# See failed login attempts
grep "Failed password" /var/log/auth.log
grep "Invalid user" /var/log/auth.log

# Kill a specific session
pkill -u username sshd
```

---

## SSH Config File (local ~/.ssh/config)

Save this on your local machine to connect easily:

```
Host myserver
    HostName 192.168.x.x
    User yourusername
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
```

Then just run: `ssh myserver`

# 👥 User Management & Permissions

---

## Create & Manage Users

```bash
# Create new user
sudo adduser username

# Create user without home dir (service accounts)
sudo useradd -r -s /usr/sbin/nologin serviceuser

# Delete user (keep home dir)
sudo deluser username

# Delete user + home directory
sudo deluser --remove-home username

# Change password
sudo passwd username

# Lock a user account
sudo usermod -L username

# Unlock
sudo usermod -U username
```

---

## Sudo & Groups

```bash
# Add user to sudo group
sudo usermod -aG sudo username

# Add to multiple groups
sudo usermod -aG sudo,docker,www-data username

# See user's groups
groups username
id username

# See all groups
cat /etc/group

# Remove from group
sudo gpasswd -d username groupname
```

---

## Fine-grained Sudo (sudoers)

```bash
# Edit safely with visudo
sudo visudo
```

Example sudoers rules:

```
# Allow user to run ALL commands
username ALL=(ALL:ALL) ALL

# Allow without password
username ALL=(ALL) NOPASSWD: ALL

# Allow only specific commands
username ALL=(ALL) /usr/bin/systemctl restart nginx, /usr/bin/apt update
```

---

## File Permissions

### chmod — Change Permissions

```bash
# Symbolic
chmod u+x file.sh          # Add execute for owner
chmod go-w file.txt        # Remove write from group & others
chmod 750 /var/www/html    # rwxr-x---

# Numeric (octal)
# 4=read, 2=write, 1=execute
chmod 644 file.txt         # rw-r--r--
chmod 755 script.sh        # rwxr-xr-x
chmod 600 ~/.ssh/id_ed25519 # rw------- (private key!)
```

### chown — Change Ownership

```bash
# Change owner
sudo chown username file.txt

# Change owner + group
sudo chown username:groupname file.txt

# Recursive (whole directory)
sudo chown -R username:groupname /var/www/mysite
```

### Special Permissions

```bash
# SetUID — run as file owner
chmod u+s /usr/bin/program

# SetGID — new files inherit group
chmod g+s /shared/folder

# Sticky bit — only owner can delete (like /tmp)
chmod +t /shared/folder
```

---

## Monitor Active Users

```bash
# Who is logged in right now
who
w

# Login history
last
last username

# Failed login attempts
lastb
grep "Failed" /var/log/auth.log

# Currently running processes by user
ps aux | grep username

# Kill all processes of a user
sudo pkill -u username
```

---

## Password Policy

```bash
# Install
sudo apt install libpam-pwquality -y

# Configure
sudo nano /etc/security/pwquality.conf
```

```
minlen = 12          # Minimum 12 characters
minclass = 3         # Must have 3 types (upper, lower, digit, special)
maxrepeat = 2        # Max 2 repeated characters
```

---

## /etc/passwd & /etc/shadow

```bash
# See all users
cat /etc/passwd

# Format: username:x:UID:GID:comment:home:shell

# See password hashes (root only)
sudo cat /etc/shadow

# Find users with login shells
grep -v "nologin\|false" /etc/passwd
```

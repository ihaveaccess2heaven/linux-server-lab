# 🔒 SSL/TLS — Encryption

---

## Option 1 — Let's Encrypt (Free, Public Domain)

```bash
# Install Certbot
sudo apt install certbot -y

# Get certificate (standalone — no web server needed)
sudo certbot certonly --standalone -d yourdomain.com

# Certificates are saved to:
# /etc/letsencrypt/live/yourdomain.com/fullchain.pem
# /etc/letsencrypt/live/yourdomain.com/privkey.pem

# Auto-renew (runs twice daily)
sudo systemctl enable certbot.timer
sudo certbot renew --dry-run   # Test renewal
```

### Nginx with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

---

## Option 2 — Self-Signed Certificate (for Lab/VM)

```bash
# Generate self-signed cert (valid 365 days)
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/lab.key \
  -out /etc/ssl/certs/lab.crt \
  -subj "/C=AZ/ST=Baku/L=Baku/O=Lab/CN=server.lab.local"

# Set correct permissions
sudo chmod 600 /etc/ssl/private/lab.key
sudo chmod 644 /etc/ssl/certs/lab.crt
```

---

## Option 3 — Local CA (Best for Lab)

Create your own Certificate Authority — trust it once, sign all your lab certs.

```bash
# Create CA
mkdir ~/myCA && cd ~/myCA
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -out ca.crt -subj "/CN=LabCA"

# Sign a server certificate
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr \
  -subj "/CN=server.lab.local"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out server.crt -days 825 -sha256

# Trust your CA on Linux client
sudo cp ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

---

## Inspect Certificates

```bash
# View cert details
openssl x509 -in /etc/ssl/certs/lab.crt -text -noout

# Check cert expiry
openssl x509 -enddate -noout -in cert.crt

# Test HTTPS connection
openssl s_client -connect yourdomain.com:443

# Check from remote
echo | openssl s_client -connect server.lab.local:443 2>/dev/null | openssl x509 -noout -dates
```

---

## Nginx SSL Config Example

```nginx
server {
    listen 443 ssl;
    server_name server.lab.local;

    ssl_certificate     /etc/ssl/certs/lab.crt;
    ssl_certificate_key /etc/ssl/private/lab.key;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
        root /var/www/html;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name server.lab.local;
    return 301 https://$host$request_uri;
}
```

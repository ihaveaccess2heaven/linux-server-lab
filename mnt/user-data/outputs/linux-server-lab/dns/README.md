# 🌐 DNS Server — BIND9

Set up your own local DNS server using BIND9.

---

## Install BIND9

```bash
sudo apt update
sudo apt install bind9 bind9utils bind9-doc -y

# Check status
sudo systemctl status bind9
```

---

## Configure named.conf.options

```bash
sudo nano /etc/bind/named.conf.options
```

```
options {
    directory "/var/cache/bind";

    // Only allow queries from local network
    allow-query { localhost; 192.168.1.0/24; };

    // Forward unknown queries to upstream DNS
    forwarders {
        1.1.1.1;    // Cloudflare
        8.8.8.8;    // Google
    };

    dnssec-validation auto;
    listen-on { any; };
};
```

---

## Create a Local Zone

```bash
sudo nano /etc/bind/named.conf.local
```

```
zone "lab.local" {
    type master;
    file "/etc/bind/zones/db.lab.local";
};

// Reverse zone (for PTR records)
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.168.1";
};
```

---

## Create Zone File

```bash
sudo mkdir /etc/bind/zones
sudo nano /etc/bind/zones/db.lab.local
```

```
;
; Zone file for lab.local
;
$TTL    604800
@   IN  SOA ns1.lab.local. admin.lab.local. (
                  2024010101  ; Serial
                  604800      ; Refresh
                  86400       ; Retry
                  2419200     ; Expire
                  604800 )    ; Negative Cache TTL

; Name servers
@       IN  NS  ns1.lab.local.

; A records
ns1     IN  A   192.168.1.10
server  IN  A   192.168.1.10
web     IN  A   192.168.1.20
db      IN  A   192.168.1.30
```

---

## Reverse Zone File

```bash
sudo nano /etc/bind/zones/db.192.168.1
```

```
$TTL    604800
@   IN  SOA ns1.lab.local. admin.lab.local. (
                  2024010101
                  604800
                  86400
                  2419200
                  604800 )

@   IN  NS  ns1.lab.local.

; PTR records
10  IN  PTR ns1.lab.local.
10  IN  PTR server.lab.local.
20  IN  PTR web.lab.local.
```

---

## Check & Restart

```bash
# Check config for errors
sudo named-checkconf

# Check zone file
sudo named-checkzone lab.local /etc/bind/zones/db.lab.local

# Restart BIND9
sudo systemctl restart bind9

# Allow DNS through firewall
sudo ufw allow 53
```

---

## Test DNS

```bash
# Query your DNS server
dig @192.168.1.10 server.lab.local

# Reverse lookup
dig @192.168.1.10 -x 192.168.1.10

# Simple test
nslookup server.lab.local 192.168.1.10

# Set server as default DNS
sudo nano /etc/resolv.conf
# Add: nameserver 192.168.1.10
```

---

## DNS Query Logs

```bash
# Enable query logging
sudo rndc querylog on

# View logs
sudo tail -f /var/log/syslog | grep named
journalctl -u bind9 -f
```

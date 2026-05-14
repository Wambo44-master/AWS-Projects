# Three-Tier Web Architecture on AWS (Manual Deployment)

## 🎯 Project Overview
This project documents the manual deployment of a highly available three-tier architecture on AWS.


## 🛠️ Prerequisites
- AWS account (Free Tier enabled)
- Basic knowledge of EC2, VPC, RDS


## 📋 Step-by-Step Instructions

### Phase 1: Network

#### Step 1: Create VPC
1. Go to VPC Console → Your VPCs → Create VPC
2. Name: `three-tier-vpc`
3. IPv4 CIDR: `10.0.0.0/24`
4. Tenancy: Default
5. Click **Create VPC**

#### Step 2: Create Subnets 
Create subnets with these CIDRs:

| Subnet Name | AZ | CIDR |
|-------------|----|----|
| Public Subnet | us-east-2a | 10.0.0.0/26 |
| Private Subnet 1 | us-east-2a | 10.0.0.64/26 |
| Private Subnet 2 | us-east-2a | 10.0.0.128/26 |
| Private Subnet 3| us-east-2b | 10.0.0.192/26|


#### Step 3: Create and Attach Internet Gateway
1. Create Internet Gateway: `three-tier-igw`
2. Attach to `three-tier-vpc`

#### Step 4: Create NAT Gateways 
1. Create NAT Gateway in `Public Subnet` → Allocate Elastic IP


#### Step 5: Create Route Tables

**Public Route Table:**
1. Create: `Public Route`
2. Add route: `0.0.0.0/0 → three-tier-igw`
3. Associate with: `Public Subnet`

**Private Route Table:**
1. Create: `Private Route`
2. Add route: `0.0.0.0/0 → NAT Gateway `
3. Associate with: `Private Subnet 1`, `Private Subnet 2`, `Private Subnet 3`


#### Step 6: Verify Network
- [ ] VPC created
- [ ] 4 subnets created
- [ ] IGW attached
- [ ] NAT Gateways with EIP
- [ ] Route tables configured

---

### Phase 2: Security Groups

Create these Security Groups in order (due to dependencies):

#### Step 1: Bastion Security Group (`bastion-sg`)
1. Inbound rules:
   | Type | Port | Source |
   |------|----|--------|
   | SSH | 22 | `YOUR-IP-ADDRESS/32` (not `0.0.0.0/0`) |
  
#### Step 2: Web Server Security Group (`Web-sg`)
1. Inbound rules:
   | Type | Port | Source |
   |------|----|--------|
   | HTTP | 80 | `0.0.0.0/0` |
   | HTTPS | 443 | `0.0.0.0/0` |
   | SSH | 22 | `Bastion-sg` |


#### Step 3: App Server Security Group (`App-sg`)
1. Inbound rules:
   | Type | Port | Source |
   |------|----|--------|
   | Custom TCP | 8080 | `Web-sg` |
   | SSH | 22 | `Bastion-sg` |
   

#### Step 4: Database Security Group (`Database-sg`)
1. Inbound rules:
   | Type | Port | Source |
   |------|----|--------|
   | MySQL/Aurora | 3306 | `App-sg` |
   | SSH | 22 | `Bastion-sg` |
   


---

### Phase 3: Deploy Resources

#### Step 1: Launch Bastion Host
1. EC2 → Launch Instance
2. Name: `bastion-host`
3. AMI: Amazon Linux 2023 (Free Tier)
4. Instance type: `t2.micro`
5. Key pair: Create or select existing
6. Network: `three-tier-vpc`
7. Subnet: `Public Subnet`
8. Enable autoassign public IP
8. Security group: `Bastion-sg`
10. Launch

#### Step 2: Create RDS Database
1. RDS → Create database
2. Engine: MySQL (or PostgreSQL)
3. Template: Free tier
4. DB instance identifier: `three-tier-db`
5. Master username: `admin`
6. Master password: (save this securely)
7. VPC: `three-tier-vpc`
8. Subnet group: Create new (include `Private Subnet 2` & ` Private Subnet 3)
9. Public access: **No**
10. Security group: `db-sg`
11. Initial database name: `appdb`
12. Create database (takes 5-10 minutes)

#### Step 3: Launch App Server
1. EC2 → Launch Instance
2. Name: `app-server`
3. AMI: Amazon Linux 2023
4. Instance type: `t2.micro`
5. Key pair: Same as bastion
6. Network: `three-tier-vpc`
7. Subnet: `Private Subnet 1`
8. Auto-assign public IP: Disable
9. Security group: `App-sg`
10. **User data** :
```bash

# 1. Update system
sudo yum update -y

# 2. Install application runtime (Python 3 + pip)
sudo yum install -y python3 python3-pip

# 3. Install database client (optional, for troubleshooting)
sudo yum install -y mysql

# 4. Create application directory
mkdir -p /var/www/app
cd /var/www/app

# 5. Create a simple Flask application
cat > app.py << 'EOF'
from flask import Flask, jsonify
import pymysql
import os

app = Flask(__name__)

# Read RDS connection info from environment variables
DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')

@app.route('/')
def index():
    return jsonify({"status": "healthy", "service": "app-server"})

@app.route('/health')
def health():
    return jsonify({"status": "ok"}), 200

@app.route('/db-status')
def db_status():
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        connection.close()
        return jsonify({"database": "connected"})
    except Exception as e:
        return jsonify({"database": "failed", "error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# 6. Install Python dependencies
pip3 install flask pymysql

# 7. Set environment variables (replace with your actual values)

# ⚠️ IMPORTANT: Replace the following values before launching:
#    - your-rds-endpoint.region.rds.amazonaws.com → your actual RDS endpoint
#    - your-secure-password → your actual database password

echo "export DB_HOST=your-rds-endpoint.region.rds.amazonaws.com" >> /etc/environment
echo "export DB_USER=admin" >> /etc/environment
echo "export DB_PASSWORD=your-secure-password" >> /etc/environment
echo "export DB_NAME=appdb" >> /etc/environment

# 8. Load environment variables for this session
source /etc/environment

# 9. Create a systemd service to run the app on boot
cat > /etc/systemd/system/app.service << 'EOF'
[Unit]
Description=App Server Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/var/www/app
ExecStart=/usr/local/bin/python3 /var/www/app/app.py
Restart=always
EnvironmentFile=/etc/environment

[Install]
WantedBy=multi-user.target
EOF

# 10. Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable app.service
sudo systemctl start app.service

# 11. Create a simple health check script for troubleshooting
cat > /home/ec2-user/health-check.sh << 'EOF'
#!/bin/bash
echo "=== App Server Health Check ==="
echo "Service status: $(sudo systemctl is-active app)"
echo "Process: $(ps aux | grep app.py | grep -v grep)"
echo "Port listening: $(sudo netstat -tlnp | grep 8080)"
echo "Database connectivity: $(mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e 'SELECT 1' 2>&1 | grep -q 1 && echo 'SUCCESS' || echo 'FAILED')"
EOF

chmod +x /home/ec2-user/health-check.sh

# 12. Create a status file for quick verification
echo "App server provisioned on: $(date)" > /home/ec2-user/provisioned.txt
echo "Hostname: $(hostname -f)" >> /home/ec2-user/provisioned.txt

```

11. Launch instance

## App Server Configuration

The app server runs a Python/Flask application that:

- Listens on port 8080
- Responds to `/health` and `/` endpoints
- Tests database connectivity via `/db-status`
- Runs as a systemd service for automatic restart
- Stores RDS credentials in `/etc/environment`

### Testing the App Server

```bash
# From web server or bastion:
curl http://<app-private-ip>:8080/health
curl http://<app-private-ip>:8080/db-status

```

#### Step 4: Launch Web Server
1. EC2 → Launch Instance
2. Name: `web server`
3. AMI: Amazon Linux 2023 (Free Tier)
4. Instance type: `t2.micro`
5. Key pair: Select existing
6. Network: `three-tier-vpc`
7. Subnet: `Public Subnet`
8. Enable autoassign public IP
8. Security group: `Web-sg`
9. Storage: Leave default (8GB gp2)
10. Configure User data

``` 
#!/bin/bash
# Installs Nginx and configures as reverse proxy to app server

# Update system
sudo yum update -y

# Install Nginx
sudo amazon-linux-extras install nginx1 -y
sudo yum install -y nginx

# ⚠️ IMPORTANT: Replace 10.0.10.10 with your actual app server private IP
# You can find this in EC2 Console → Instances → app-server → Private IP
APP_SERVER_IP="10.0.10.10"

# Configure Nginx as reverse proxy
sudo cat > /etc/nginx/conf.d/app.conf << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://${APP_SERVER_IP}:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

     location /health {
        proxy_pass http://${APP_SERVER_IP}:8080/health;
    }

    location /db-status {
        proxy_pass http://${APP_SERVER_IP}:8080/db-status;
    }
    location /static/ {
        root /var/www/html;
        expires 1d;
    }
}
EOF

# Create simple fallback page
echo "<h1>Web Server is Running</h1>" | sudo tee /usr/share/nginx/html/index.html

# Start and enable Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Log provision
echo "Web server provisioned on: $(date)" > /home/ec2-user/provisioned.txt
echo "App server target: ${APP_SERVER_IP}" >> /home/ec2-user/provisioned.txt


```

11. Launch instance

## Web Server Configuration
The web server runs Nginx as a reverse proxy that:

1. Listens on port 80 for incoming HTTP traffic
2. Forwards API requests to the app server on port 8080
3. Serves static files (CSS, JavaScript, images) directly
4. Provides a fallback page if the app server is unreachable
5.Runs as a systemd service for automatic restart
6. Stores the app server IP in the Nginx configuration file

### From your local machine or browser:
```
curl http://<web-server-public-ip>:80
```

### Check if Nginx is running (SSH into web server):
```
sudo systemctl status nginx
```
### Verify reverse proxy configuration:
```
sudo nginx -t
```
### Check the provision log:
```
cat /home/ec2-user/provisioned.txt
```

### Phase 4: Test the Architecture
Step 1: Test Bastion → App Server

bash
### SSH into bastion
```
ssh -i your-key.pem ec2-user@<bastion-public-ip>
```
### From bastion, SSH into app server (using private IP from EC2 console)
```
ssh -i your-key.pem ec2-user@<app-server-private-ip>
```
Step 2: Test App → Database
From the app server, install MySQL client and test connection:

```
bash
sudo yum install mysql -y
mysql -h <rds-endpoint> -u admin -p
```
Step 3: Test Web → App (once web server is deployed)

```
bash
curl http://<web-server-public-ip>:80
```



## 🧹 Clean Up Instructions

To avoid ongoing charges, delete resources in this order:

1. Terminate EC2 instances (web-server, app-server, bastion-host)
2. Delete RDS database (final snapshot optional)
3. Delete NAT Gateway
4. Release Elastic IP
5. Detach and delete Internet Gateway
6. Delete subnets (4)
7. Delete route tables (2)
8. Delete VPC

## 💰 Cost Breakdown (Free Tier)

| Service | Free Tier Limit | Notes |
|---------|-----------------|-------|
| EC2 t2.micro | 750 hours/month | 3 instances = ~720 hours/month (within limit if run together) |
| RDS db.t2.micro | 750 hours/month | Within limit |
| NAT Gateway | Not free | ~$0.045/hour — delete after testing |
| Data transfer | First 100GB free | Within limit |


#!/bin/bash

# HA Three-Tier Architecture on AWS (CLI)

set -e  # Stop script if any command fails

# Variables
VPC_CIDR="10.0.0.0/23"
PUB_SUBNET_A_CIDR="10.0.0.0/25"
PUB_SUBNET_B_CIDR="10.0.0.128/25"
APP_SUBNET_A_CIDR="10.0.1.0/25"
APP_SUBNET_B_CIDR="10.0.1.128/25"
DB_SUBNET_A_CIDR="10.0.2.0/25"
DB_SUBNET_B_CIDR="10.0.2.128/25"
DB_PASSWORD="YourSecurePassword123!"
KEY_NAME="your-key-pair-name"
REGION="us-east-2"

echo "Creating VPC"
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=ha-vpc
echo "VPC created: $VPC_ID"

# Enable DNS
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support '{"Value":true}'
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames '{"Value":true}'

echo " Creating Subnets "
PUB_SUBNET_A=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUB_SUBNET_A_CIDR --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
PUB_SUBNET_B=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUB_SUBNET_B_CIDR --availability-zone ${REGION}b --query 'Subnet.SubnetId' --output text)
APP_SUBNET_A=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $APP_SUBNET_A_CIDR --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
APP_SUBNET_B=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $APP_SUBNET_B_CIDR --availability-zone ${REGION}b --query 'Subnet.SubnetId' --output text)
DB_SUBNET_A=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $DB_SUBNET_A_CIDR --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
DB_SUBNET_B=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $DB_SUBNET_B_CIDR --availability-zone ${REGION}b --query 'Subnet.SubnetId' --output text)

# Enable auto-assign public IP on public subnets
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_A --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_B --map-public-ip-on-launch

echo " Creating Internet Gateway "
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

echo " Creating NAT Gateways "
EIP_A=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
EIP_B=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)

NAT_A=$(aws ec2 create-nat-gateway --subnet-id $PUB_SUBNET_A --allocation-id $EIP_A --query 'NatGateway.NatGatewayId' --output text)
NAT_B=$(aws ec2 create-nat-gateway --subnet-id $PUB_SUBNET_B --allocation-id $EIP_B --query 'NatGateway.NatGatewayId' --output text)

echo "Waiting for NAT Gateways (1-2 minutes)..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_A $NAT_B

echo " Creating Route Tables "
PUB_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $PUB_RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --route-table-id $PUB_RT --subnet-id $PUB_SUBNET_A
aws ec2 associate-route-table --route-table-id $PUB_RT --subnet-id $PUB_SUBNET_B

PRIV_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $PRIV_RT --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_A
aws ec2 associate-route-table --route-table-id $PRIV_RT --subnet-id $APP_SUBNET_A
aws ec2 associate-route-table --route-table-id $PRIV_RT --subnet-id $APP_SUBNET_B
aws ec2 associate-route-table --route-table-id $PRIV_RT --subnet-id $DB_SUBNET_A
aws ec2 associate-route-table --route-table-id $PRIV_RT --subnet-id $DB_SUBNET_B

echo " Creating Security Groups "
# Bastion SG
BASTION_SG=$(aws ec2 create-security-group --group-name bastion-sg --description "Bastion host SG" --vpc-id $VPC_ID --query 'GroupId' --output text)
MY_IP=$(curl -s https://checkip.amazonaws.com)/32
aws ec2 authorize-security-group-ingress --group-id $BASTION_SG --protocol tcp --port 22 --cidr $MY_IP

# Web SG
WEB_SG=$(aws ec2 create-security-group --group-name web-sg --description "Web server SG" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $WEB_SG --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $WEB_SG --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $WEB_SG --protocol tcp --port 22 --source-group $BASTION_SG

# App SG
APP_SG=$(aws ec2 create-security-group --group-name app-sg --description "App server SG" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $APP_SG --protocol tcp --port 8080 --source-group $WEB_SG
aws ec2 authorize-security-group-ingress --group-id $APP_SG --protocol tcp --port 22 --source-group $BASTION_SG

# DB SG
DB_SG=$(aws ec2 create-security-group --group-name db-sg --description "Database SG" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $DB_SG --protocol tcp --port 3306 --source-group $APP_SG
aws ec2 authorize-security-group-ingress --group-id $DB_SG --protocol tcp --port 22 --source-group $BASTION_SG

echo " Creating RDS Database (Multi-AZ) "
DB_SUBNET_GROUP="ha-db-subnet-group"
aws rds create-db-subnet-group --db-subnet-group-name $DB_SUBNET_GROUP --db-subnet-group-description "HA DB subnets" --subnet-ids $DB_SUBNET_A $DB_SUBNET_B

aws rds create-db-instance \
    --db-name appdb \
    --db-instance-identifier ha-db \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --allocated-storage 20 \
    --master-username admin \
    --master-user-password $DB_PASSWORD \
    --multi-az \
    --db-subnet-group-name $DB_SUBNET_GROUP \
    --vpc-security-group-ids $DB_SG \
    --backup-retention-period 7 \
    --preferred-backup-window "03:00-04:00"

echo "Waiting for RDS to become available..."
aws rds wait db-instance-available --db-instance-identifier ha-db

RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier ha-db --query 'DBInstances[0].Endpoint.Address' --output text)

echo " Creating Target Groups and Load Balancer "
TG_ARN=$(aws elbv2 create-target-group --name ha-tg --protocol HTTP --port 8080 --vpc-id $VPC_ID --health-check-path /health --query 'TargetGroups[0].TargetGroupArn' --output text)

ALB_SG=$(aws ec2 create-security-group --group-name alb-sg --description "ALB SG" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 80 --cidr 0.0.0.0/0

ALB_ARN=$(aws elbv2 create-load-balancer --name ha-alb --subnets $PUB_SUBNET_A $PUB_SUBNET_B --security-groups $ALB_SG --scheme internet-facing --query 'LoadBalancers[0].LoadBalancerArn' --output text)

aws elbv2 create-listener --load-balancer-arn $ALB_ARN --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$TG_ARN

ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN --query 'LoadBalancers[0].DNSName' --output text)

echo " Launching Bastion Host "
BASTION_ID=$(aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $PUB_SUBNET_A \
    --security-group-ids $BASTION_SG \
    --associate-public-ip-address \
    --query 'Instances[0].InstanceId' --output text)

echo " Launching App Servers (Private Subnets) "
APP_USERDATA=$(cat <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y python3 python3-pip mysql
mkdir -p /var/www/app
cd /var/www/app

cat > app.py << 'EOL'
from flask import Flask, jsonify
import pymysql
import os

app = Flask(__name__)

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
        connection = pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD, database=DB_NAME)
        connection.close()
        return jsonify({"database": "connected"})
    except Exception as e:
        return jsonify({"database": "failed", "error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOL

pip3 install flask pymysql
echo "export DB_HOST=$RDS_ENDPOINT" >> /etc/environment
echo "export DB_USER=admin" >> /etc/environment
echo "export DB_PASSWORD=$DB_PASSWORD" >> /etc/environment
echo "export DB_NAME=appdb" >> /etc/environment
source /etc/environment

cat > /etc/systemd/system/app.service << 'EOL'
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
EOL

sudo systemctl daemon-reload
sudo systemctl enable app.service
sudo systemctl start app.service
EOF
)

APP_USERDATA_B64=$(echo "$APP_USERDATA" | base64 -w 0)

APP_A=$(aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $APP_SUBNET_A \
    --security-group-ids $APP_SG \
    --user-data "$APP_USERDATA_B64" \
    --query 'Instances[0].InstanceId' --output text)

APP_B=$(aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $APP_SUBNET_B \
    --security-group-ids $APP_SG \
    --user-data "$APP_USERDATA_B64" \
    --query 'Instances[0].InstanceId' --output text)

echo " Launching Web Servers "
WEB_USERDATA=$(cat <<EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo yum install -y nginx

APP1_IP=$(aws ec2 describe-instances --instance-ids $APP_A --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
APP2_IP=$(aws ec2 describe-instances --instance-ids $APP_B --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)

sudo cat > /etc/nginx/conf.d/app.conf << EOL
upstream app_backend {
    server ${APP1_IP}:8080;
    server ${APP2_IP}:8080;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /health {
        proxy_pass http://app_backend/health;
    }

    location /db-status {
        proxy_pass http://app_backend/db-status;
    }
}
EOL

sudo systemctl enable nginx
sudo systemctl start nginx
EOF
)

WEB_USERDATA_B64=$(echo "$WEB_USERDATA" | base64 -w 0)

WEB_A=$(aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $PUB_SUBNET_A \
    --security-group-ids $WEB_SG \
    --user-data "$WEB_USERDATA_B64" \
    --query 'Instances[0].InstanceId' --output text)

WEB_B=$(aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $PUB_SUBNET_B \
    --security-group-ids $WEB_SG \
    --user-data "$WEB_USERDATA_B64" \
    --query 'Instances[0].InstanceId' --output text)

# Register web servers with target group
aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=$WEB_A Id=$WEB_B


echo "DEPLOYMENT COMPLETE!"
echo "ALB DNS: $ALB_DNS"
echo "RDS Endpoint: $RDS_ENDPOINT"
echo "Bastion ID: $BASTION_ID"
echo ""
echo "Test the application: curl http://$ALB_DNS"

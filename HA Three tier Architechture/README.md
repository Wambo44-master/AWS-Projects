# 🚀 AWS Highly Available Three-Tier Architecture - CLI Automated Deployment

## 📋 Project Overview

This project automates the deployment of a **production-ready, highly available three-tier architecture** on AWS using a Bash script that calls the AWS CLI.

The script creates:
- VPC with 6 subnets across 2 Availability Zones
- Internet Gateway and NAT Gateways (one per AZ)
- Public and private route tables
- Security groups (bastion, web, app, database, ALB)
- RDS MySQL database (Multi-AZ for automatic failover)
- Application Load Balancer (internet-facing)
- Web servers (one per AZ) with Nginx reverse proxy
- App servers (one per AZ) with Python/Flask application

## 🛠️ Prerequisites

- AWS account (Free Tier eligible)
- AWS CLI installed and configured (`aws configure`)
- EC2 key pair in `us-east-2` region
- Bash shell (Linux, macOS, or WSL on Windows)

## 📂 Repository Contents

| File | Description |
|------|-------------|
| `deploy-ha.sh` | Main deployment script |
| `cleanup.sh` | Destroys all created resources |
| `architecture-diagram.md` | Visual architecture diagram |

## 🚀 Quick Start


### Clone the repository
```
git clone https://github.com/yourusername/aws-ha-three-tier-cli.git
cd aws-ha-three-tier-cli
````
### Make scripts executable
```
chmod +x deploy-ha.sh cleanup.sh
```

### Edit the key pair name (required)

Open deploy-ha.sh and change KEY_NAME="your-key-pair-name"

### Run the deployment
```
./deploy-ha.sh
```

## Expected output

After successful deployment, your output will be similar to:

```
DEPLOYMENT COMPLETE!

ALB DNS: ha-alb-1234567890.us-east-2.elb.amazonaws.com
RDS Endpoint: ha-db.abcdefghijklmnop.us-east-2.rds.amazonaws.com
Bastion ID: i-0a1b2c3d4e5f67890

````
Test the application: 
```
curl http://ha-alb-1234567890.us-east-2.elb.amazonaws.com
```

**Note**: Your actual DNS names, endpoints and instance IDs will be unique to your deployment.

### Output Explanation

ALB DNS - Public endpoint of your Application Load Balancer and this is used to test the application.
RDS Endpoint - Connection endpoint for the MySQL database used by app servers.
Bastion ID - Instance ID of the bastion host for secure SSH access.


## Testing the Deployment

Replace <ALB-DNS> with your actual ALB DNS from the output

```
curl http://<ALB-DNS>/health
curl http://<ALB-DNS>/db-status

```

Expected Responses:

- /health - {"status": "ok"} 
- / db-status - {"database": "connected"}


## Failover Testing

1. Stop web server in AZ-a which results in the ALB routing all traffic to web server in AZ-b.

2. Stop app server in AZ-a which results in web servers proxy to healthy app server in AZ-b.

3. RDS primary AZ fails which results in the Multi-az automatically failing over to standby.


## Troubleshooting

1. Unable to locate credentials - Run aws configure.
2. Key Pair does not exist - Change KEY_NAME in script or create the key pair.
3. RDS takes too long - Wait a few minutes
4. Permission denied - Run chmod +x deploy.sh



## 💰 Cost Breakdown (Free Tier)

| Service | Free Tier Limit | Notes |
|---------|-----------------|-------|
| EC2 t2.micro | 750 hours/month | 4 instances = ~750 hours/month (within limit if run together) |
| RDS db.t2.micro | 750 hours/month | Within limit |
| NAT Gateway (2)| Not free | ~$0.045/hour — delete after testing |
| Data transfer | First 100GB free | Within limit |
|ALB | Not free | ~$0.0225/hr 


## Clean up

Run clean.sh after testing to avoid incurring costs for resources you are no longer using.
The script automatically destroys all resources created by deploy.sh in the correct dependency order:   

1. Terminates EC2 instances.
2. Deletes Application Load Balancer and Target group.
3. Deletes RDS Database.
4. Deletes NAT gateways.
5. Releases Elastic IPs.
6. Deletes Route tables.
7. Deletes security groups.
8. Deletes subnets.
9. Detaches and deletes Internet Gateway.
10. Deletes VPC.
11. Deltes DB Subnet Group.


### ⚠ Important

1. RDS deletion takes 10- 15 minutes and the script waits for completion.
2. NAT Gateway Deletion takes about 2 minutes and the script includes a wait.
3. If **no resources found**, the script exits gracefully if noting to clean up.
4. It is important that all your resources run in the same AWS region.



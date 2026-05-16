#!/bin/bash

# Cleanup Script for HA Three-Tier Architecture

# This script destroys all resources created by deploy-ha.sh
# Run this to avoid ongoing AWS charges


set -e  # Stop script if any command fails


echo "Starting Cleanup of HA Three-Tier Architecture"



# Step 1: Get Resource IDs


echo ""
echo "Step 1: Looking up resource IDs..."

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=ha-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo "")
if [ -n "$VPC_ID" ]; then
    echo "Found VPC: $VPC_ID"
else
    echo "No VPC found. Nothing to clean up."
    exit 0
fi

# Get ALB ARN
ALB_ARN=$(aws elbv2 describe-load-balancers --names ha-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo "")
[ -n "$ALB_ARN" ] && echo "Found ALB: $ALB_ARN"

# Get Target Group ARN
TG_ARN=$(aws elbv2 describe-target-groups --names ha-tg --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")
[ -n "$TG_ARN" ] && echo "Found Target Group: $TG_ARN"

# Get NAT Gateway IDs
NAT_A=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=ha-nat-a" --query 'NatGateways[0].NatGatewayId' --output text 2>/dev/null || echo "")
NAT_B=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=ha-nat-b" --query 'NatGateways[0].NatGatewayId' --output text 2>/dev/null || echo "")
[ -n "$NAT_A" ] && echo "Found NAT Gateway A: $NAT_A"
[ -n "$NAT_B" ] && echo "Found NAT Gateway B: $NAT_B"

# Get Security Group IDs
ALB_SG=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=alb-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")
WEB_SG=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=web-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")
APP_SG=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=app-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")
DB_SG=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=db-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")
BASTION_SG=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=bastion-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")

# Get Subnet IDs
PUB_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ha-public-a" --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")
PUB_SUBNET_B=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ha-public-b" --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")
APP_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ha-app-a" --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")
APP_SUBNET_B=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ha-app-b" --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")
DB_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ha-db-a" --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")
DB_SUBNET_B=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ha-db-b" --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")

# Get IGW ID
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null || echo "")
[ -n "$IGW_ID" ] && echo "Found IGW: $IGW_ID"

# Get Route Table IDs
PUB_RT=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ha-public-rt" --query 'RouteTables[0].RouteTableId' --output text 2>/dev/null || echo "")
PRIV_RT=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ha-private-rt" --query 'RouteTables[0].RouteTableId' --output text 2>/dev/null || echo "")
[ -n "$PUB_RT" ] && echo "Found Public Route Table: $PUB_RT"
[ -n "$PRIV_RT" ] && echo "Found Private Route Table: $PRIV_RT"

# Get EIP Allocation IDs
EIP_A=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=ha-eip-a" --query 'Addresses[0].AllocationId' --output text 2>/dev/null || echo "")
EIP_B=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=ha-eip-b" --query 'Addresses[0].AllocationId' --output text 2>/dev/null || echo "")
[ -n "$EIP_A" ] && echo "Found EIP A: $EIP_A"
[ -n "$EIP_B" ] && echo "Found EIP B: $EIP_B"


# Step 2: Terminate EC2 Instances

echo ""
echo "Step 2: Terminating EC2 instances..."

INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text 2>/dev/null || echo "")

if [ -n "$INSTANCE_IDS" ]; then
    echo "Terminating instances: $INSTANCE_IDS"
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    echo "Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
    echo "Instances terminated."
else
    echo "No instances found to terminate."
fi


# Step 3: Delete Load Balancer and Target Group

echo ""
echo "Step 3: Deleting Load Balancer and Target Group..."

if [ -n "$ALB_ARN" ]; then
    echo "Deleting ALB: $ALB_ARN"
    aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
    echo "Waiting for ALB deletion..."
    sleep 30
fi

if [ -n "$TG_ARN" ]; then
    echo "Deleting Target Group: $TG_ARN"
    aws elbv2 delete-target-group --target-group-arn $TG_ARN
fi


# Step 4: Delete RDS Database

echo ""
echo "Step 4: Deleting RDS Database..."

RDS_ID="ha-db"
if aws rds describe-db-instances --db-instance-identifier $RDS_ID &>/dev/null; then
    echo "Deleting RDS instance: $RDS_ID"
    aws rds delete-db-instance --db-instance-identifier $RDS_ID --skip-final-snapshot
    echo "Waiting for RDS deletion (this takes several minutes)..."
    aws rds wait db-instance-deleted --db-instance-identifier $RDS_ID
    echo "RDS instance deleted."
else
    echo "RDS instance not found."
fi


# Step 5: Delete NAT Gateways

echo ""
echo "Step 5: Deleting NAT Gateways..."

if [ -n "$NAT_A" ]; then
    echo "Deleting NAT Gateway A: $NAT_A"
    aws ec2 delete-nat-gateway --nat-gateway-id $NAT_A
fi

if [ -n "$NAT_B" ]; then
    echo "Deleting NAT Gateway B: $NAT_B"
    aws ec2 delete-nat-gateway --nat-gateway-id $NAT_B
fi

if [ -n "$NAT_A" ] || [ -n "$NAT_B" ]; then
    echo "Waiting for NAT Gateways to delete..."
    sleep 60
fi


# Step 6: Release Elastic IPs

echo ""
echo "Step 6: Releasing Elastic IPs..."

if [ -n "$EIP_A" ]; then
    echo "Releasing EIP A: $EIP_A"
    aws ec2 release-address --allocation-id $EIP_A
fi

if [ -n "$EIP_B" ]; then
    echo "Releasing EIP B: $EIP_B"
    aws ec2 release-address --allocation-id $EIP_B
fi


# Step 7: Delete Route Tables

echo ""
echo "Step 7: Deleting Route Tables..."

if [ -n "$PUB_RT" ]; then
    # Remove associations first
    ASSOC_IDS=$(aws ec2 describe-route-tables --route-table-ids $PUB_RT --query 'RouteTables[0].Associations[].RouteTableAssociationId' --output text 2>/dev/null || echo "")
    for ASSOC_ID in $ASSOC_IDS; do
        echo "Disassociating: $ASSOC_ID"
        aws ec2 disassociate-route-table --association-id $ASSOC_ID
    done
    echo "Deleting Public Route Table: $PUB_RT"
    aws ec2 delete-route-table --route-table-id $PUB_RT
fi

if [ -n "$PRIV_RT" ]; then
    ASSOC_IDS=$(aws ec2 describe-route-tables --route-table-ids $PRIV_RT --query 'RouteTables[0].Associations[].RouteTableAssociationId' --output text 2>/dev/null || echo "")
    for ASSOC_ID in $ASSOC_IDS; do
        echo "Disassociating: $ASSOC_ID"
        aws ec2 disassociate-route-table --association-id $ASSOC_ID
    done
    echo "Deleting Private Route Table: $PRIV_RT"
    aws ec2 delete-route-table --route-table-id $PRIV_RT
fi


# Step 8: Delete Security Groups

echo ""
echo "Step 8: Deleting Security Groups..."

for SG in $ALB_SG $WEB_SG $APP_SG $DB_SG $BASTION_SG; do
    if [ -n "$SG" ]; then
        echo "Deleting Security Group: $SG"
        aws ec2 delete-security-group --group-id $SG 2>/dev/null || echo "  (skipped - may have dependencies)"
    fi
done


# Step 9: Delete Subnets

echo ""
echo "Step 9: Deleting Subnets..."

for SUBNET in $PUB_SUBNET_A $PUB_SUBNET_B $APP_SUBNET_A $APP_SUBNET_B $DB_SUBNET_A $DB_SUBNET_B; do
    if [ -n "$SUBNET" ]; then
        echo "Deleting Subnet: $SUBNET"
        aws ec2 delete-subnet --subnet-id $SUBNET
    fi
done


# Step 10: Detach and Delete Internet Gateway

echo ""
echo "Step 10: Deleting Internet Gateway..."

if [ -n "$IGW_ID" ] && [ -n "$VPC_ID" ]; then
    echo "Detaching IGW: $IGW_ID from VPC: $VPC_ID"
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
    echo "Deleting IGW: $IGW_ID"
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi


# Step 11: Delete VPC

echo ""
echo "Step 11: Deleting VPC..."

if [ -n "$VPC_ID" ]; then
    echo "Deleting VPC: $VPC_ID"
    aws ec2 delete-vpc --vpc-id $VPC_ID
fi


# Step 12: Delete DB Subnet Group

echo ""
echo "Step 12: Deleting DB Subnet Group..."

aws rds delete-db-subnet-group --db-subnet-group-name ha-db-subnet-group 2>/dev/null || echo "DB Subnet Group not found or already deleted."


# Complete

echo "CLEANUP COMPLETE!"
echo "=========================================="
echo "All resources from the HA Three-Tier deployment have been deleted."
echo "Check the AWS Console to verify no resources remain."
echo "=========================================="

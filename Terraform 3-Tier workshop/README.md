# Terraform 3-Tier Workshop (Study Project)

## 📋 Overview
This project documents my study of a production-grade 3-tier AWS architecture built using Terraform. I attended the workshop led by Hashicorp User Group-Accra and studied the complete codebase to understand how to structure Terraform projects for real-world maintainability.

**Original Workshop:** [kodcapsule/terraform-3tier-workshop](https://github.com/kodcapsule/terraform-3tier-workshop)

## 🎯 What I Learned
- How to structure Terraform projects for multi-environment deployments (dev, staging, prod)
- Building custom modules for VPC and EC2
- Using community modules for Security Groups and RDS
- Configuring remote state with S3 backend and state locking
- Applying least-privilege security between tiers
- Managing dependencies and troubleshooting Terraform errors

## 🛠️ Technologies Covered
- Terraform (~> 1.5)
- AWS (VPC, EC2, RDS, S3, Security Groups)
- Custom and Community Modules
- Remote State Management

## 🏗️ Architecture Studied
The workshop covers a standard 3-tier architecture:
- **Web Tier:** EC2 instances in public subnets
- **App Tier:** EC2 instances in private subnets
- **Data Tier:** RDS PostgreSQL in private subnets

## 📁 Project Structure (Studied)
The workshop codebase follows best practices:
terraform-3tier-workshop/
│
├── books/                          # Supplementary reading and reference material
│
├── images/                         # Architecture diagrams
│   ├── 3-tier-architecture.png
│   └── 3-tier-architecture-future-imp.png
│
├── state-bootstrap/                # One-time setup: S3 bucket 
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── modules/                        # Reusable custom Terraform modules
│   ├── vpc/                        # Custom VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/                        # Custom EC2 module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environment/
│   └── dev/                        # Dev environment root configuration
│       ├── backend.tf              # Remote state backend config
│       ├── provider.tf             # AWS provider config
│       ├── main.tf                 # Module calls and resource definitions
│       ├── variables.tf            # Input variables
│       ├── terraform.tfvars        # Variable values (optional) NOTE:(do not commit secrets)
│       └── outputs.tf              # Environment outputs
│
├── .gitignore
└── Readme.md


## 🚀 What I Plan to Do Next
- Deploy this architecture
- Extend the workshop by adding an Application Load Balancer and Auto Scaling Groups
- Create staging and production environments

## 📅 Date Studied
June 2026

## 🔗 Links
- [Original Workshop Repository](https://github.com/kodcapsule/terraform-3tier-workshop)

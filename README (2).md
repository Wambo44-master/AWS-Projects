<img src="https://cdn.prod.website-files.com/677c400686e724409a5a7409/6790ad949cf622dc8dcd9fe4_nextwork-logo-leather.svg" alt="NextWork" width="300" />

# Launch a Kubernetes Cluster

**Project Link:** [View Project](http://nextwork.ai/projects/aws-compute-eks1)

**Author:** Nicole Wainaina  
**Email:** zolianzozo60@gmail.com

---

## Launch a Kubernetes Cluster

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-eks1_e5f6g7h8)

---

## Introducing Today's Project!

In this project, I will launch a Kubernetes cluster using Amazon EKS.

### What is Amazon EKS?

### One thing I didn't expect

### This project took me...

---

## What is Kubernetes?

Kubernetes is a container orchestration platform.  It makes sure all your containers are running where they should, scales containers automatically to meet demand levels, and even restarts containers if something crashes.

It’s THE standard tool for keeping large, container-based applications steady and easy to scale with traffic hence why many companies and developers use Kubernetes to manage containers.

I used eksctl to create a Kubernetes cluster in EC2 connect. The create cluster command I ran:

eksctl create cluster \
--name nextwork-eks-cluster \
--nodegroup-name nextwork-nodegroup \
--node-type t3.micro \
--nodes 3 \
--nodes-min 1 \
--nodes-max 3 \
--version 1.33 \
--region your-region-code

which:
1. Set up an EKS cluster named nextwork-eks-cluster
2. Launch a node group called nextwork-nodegroup.
3. Use t3.micro EC2 instances as nodes.
4. Start your node group with 3 nodes and automatically scale between 1 (minimum) and 3 nodes (maximum) based on demand.
5. Use Kubernetes version 1.31 for the cluster setup.

I initially ran into two errors while using eksctl. The first one was because eksctl had not been previously installed. The second one was because my ec2 instance lacked the necessary permissions to run eksctl

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-eks1_ff9bfc221)

---

## eksctl and CloudFormation

CloudFormation helped create my EKS cluster because CloudFormation is AWS’s service for setting up infrastructure as code. When you write a template describing the resources you need, CloudFormation handles creating and configuring those resources.
It created VPC resources because these resources set up a private, secure network for containers to connect with each other and the internet while keeping my app private.

There was also a second CloudFormation stack which is a node group which is a group of  EC2 instances that will run the containers.The difference between a cluster and node group is that a cluster refers to the entire environment while a node group comprises of nodes that run your containers.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-eks1_w3e4r5t6)

---

## The EKS console

I had to create an IAM access entry in order to connect AWS and Kubernetes. IAM is used by AWS as it's permissions system while Kubernetes uses Role Based Access Control. The entry maps my IAM role to an RBAC role, so the cluster lets me access my nodes.. 

It took about 20 minutes to create my cluster. 

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-eks1_e5f6g7h8)

---

## EXTRA: Deleting nodes

Did you know you can find your EKS cluster's nodes in Amazon EC2? This is because when you create a node, it is actually an EC2 instance.

Desired size means the number of nodes you want to run in the node group. Mininum and maximum sizes are helpful for scaling the node group by maintaining the number of nodes specified during cluster creation.

When I deleted my EC2 instances, after a few minutes I saw that new instances were created. This is because the desired number of nodes during cluster creation was 3. So when the EC2 instances were deleted, new instances were launced to replace them.

![Image](http://nextwork.ai/restful_olive_calm_jellyfish/uploads/aws-compute-eks1_q7r8s9t0)

---

---

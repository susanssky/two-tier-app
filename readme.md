# Introduction
In an effort to deepen my understanding of AWS and network architecture, I undertook the challenge of building a two-tier application on AWS.

My objective was to create a full-stack application that would monitor EC2 CPU usage, incorporating various AWS services and best practices for network security and scalability.

I began by establishing a VPC with multiple Availability Zones. Within each zone, I configured public subnets for EC2 instances and private subnets for RDS databases. I meticulously set up route tables and security groups to manage network traffic and access controls. The RDS was placed in a private subnet, accessible only to specific EC2 instances and load balancers.

I crafted EC2 user data scripts to automate the installation of necessary software, including the SSM agent (System Manager) and Docker. This allowed for seamless deployment of backend services via Docker images. I then created an AMI template from this configuration to facilitate auto-scaling based on CPU utilisation.

To ensure high availability and efficient traffic distribution, I implemented a load balancer. For enhanced security and performance, I optionally integrated CloudFront for the frontend, utilising API Gateway for backend communication. Additionally, I set up an event-driven notification system using EventBridge, SNS, and AWS Chatbot to alert the development team of EC2 status changes via Slack.

The resulting architecture demonstrated a robust, scalable, and secure two-tier application. It showcased effective use of AWS services, including VPC, EC2, RDS, Auto Scaling, Load Balancing, CloudFront, and various monitoring and notification tools. This project significantly enhanced my practical knowledge of AWS and network architecture principles.

# Cloud Service
- S3
- API Gateway
- Cloudfront
- EC2
- RDS
- Auto Scaling
- Load Balancer
- System Manager
- SNS
- EventBrdige
- AWS Chatbot
- VPC

# Tool
- Docker
- Terraform
- Github Actions
#!/bin/bash

# Algorithm: Create an AWS EC2 Instance Using a Shell Script
# Start the script.
# Check whether the user has root privileges if required.
# Check whether AWS CLI is installed.
# Verify AWS credentials using aws sts get-caller-identity.
# Configure the AWS region.
# Retrieve the latest Amazon Linux AMI ID.
# Identify the key pair, security group, and subnet.
# Create an EC2 instance using aws ec2 run-instances.
# Check whether the instance creation was successful.
# Wait until the EC2 instance reaches the running state.
# Retrieve the EC2 instance ID and public IP address.
# Display the instance details.
# Stop the script.

#configuration
REGION="us-east-1"  # Specify the AWS region
INSTANCE_TYPE="t2.micro"  # Specify the instance type
 
aws ec2 run-instances \
    --image-id "ami-0220d79f3f480ecf5" \
    --instance-type "t3.micro" \
    --security-group "RS-Common" \
     --region "us-east-1" \
      --query 'Instances[0].InstanceId' \
      --output text


aws ec2 run-instances --image-id "ami-0055977a6e828a4f4" --instance-type "t3.micro" --security-groups "RS-Common" --region "us-east-1"

   
aws ec2 describe-instances    
 --instance-ids i-07ce2926522728dde   
 --query "Reservations[*].Instances[*].PublicIpAddress"   
 --output text

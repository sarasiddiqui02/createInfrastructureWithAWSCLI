#!/bin/bash

# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=project1VPC}]' --query 'Vpc.VpcId' --output text --region us-east-1)
echo "VPC created with ID: $vpc_id"

# Create internet gateway
gateway_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text --region us-east-1)
echo "Internet gateway created with ID: $gateway_id"

# Attach internet gateway to VPC
aws ec2 attach-internet-gateway --internet-gateway-id $gateway_id --vpc-id $vpc_id --region us-east-1
echo "Internet gateway attached to VPC"

# Create public subnet
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.0.0/24 --query 'Subnet.SubnetId' --output text --region us-east-1)
echo "Public subnet created with ID: $subnet_id"

# Enable auto-assign public IP on public subnet
aws ec2 modify-subnet-attribute --subnet-id $subnet_id --map-public-ip-on-launch --region us-east-1
echo "Enabled auto-assign public IP on public subnet"

# Create public route table
route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text --region us-east-1)
echo "Public route table created with ID: $route_table_id"

# Add route to internet gateway in public route table
aws ec2 create-route --route-table-id $route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $gateway_id --region us-east-1
echo "Added route to internet gateway in public route table"

# Associate public subnet with public route table
aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $route_table_id --region us-east-1
echo "Associated public subnet with public route table"

# Create security group for SSH access
security_group_id=$(aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id $vpc_id --query 'GroupId' --output text --region us-east-1)
echo "Security group created with ID: $security_group_id"

# Authorize SSH inbound rule
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0 --region us-east-1
echo "SSH inbound rule added to security group"

# Launch Master node 1
master_instance_id=$(aws ec2 run-instances --image-id ami-0e58f89e91723af4c --instance-type t2.medium --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=master-node-01},{Key=project,Value=wecloud}]' --subnet-id $subnet_id --security-group-ids $security_group_id --region us-east-1 --user-data "$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3.10
apt-get install -y nodejs=18.0
apt-get install -y openjdk-11-jdk
apt-get install -y docker.io
EOF
)"
)
echo "Master node 1 launched with ID: $master_instance_id"

# Launch Worker node 1
worker1_instance_id=$(aws ec2 run-instances --image-id ami-0e58f89e91723af4c --instance-type t2.medium --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=worker-node-01},{Key=project,Value=wecloud}]' --subnet-id $subnet_id --security-group-ids $security_group_id --region us-east-1 --user-data "$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3.10
apt-get install -y nodejs=18.0
apt-get install -y openjdk-11-jdk
apt-get install -y docker.io
EOF
)"
)
echo "Worker node 1 launched with ID: $worker1_instance_id"

# Launch Worker node 2
worker2_instance_id=$(aws ec2 run-instances --image-id ami-0e58f89e91723af4c --instance-type t2.medium --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=worker-node-02},{Key=project,Value=wecloud}]' --subnet-id $subnet_id --security-group-ids $security_group_id --region us-east-1 --user-data "$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3.10
apt-get install -y nodejs=18.0
apt-get install -y openjdk-11-jdk
apt-get install -y docker.io
EOF
)"
)
echo "Worker node 2 launched with ID: $worker2_instance_id"

# Wait for instances to be running
aws ec2 wait instance-running --instance-ids $master_instance_id $worker1_instance_id $worker2_instance_id --region us-east-1
echo "All instances are running"

# Allow instances to communicate with each other via security group
aws ec2 modify-instance-attribute --instance-id $master_instance_id --groups $security_group_id --region us-east-1
aws ec2 modify-instance-attribute --instance-id $worker1_instance_id --groups $security_group_id --region us-east-1
aws ec2 modify-instance-attribute --instance-id $worker2_instance_id --groups $security_group_id --region us-east-1
echo "Instances can communicate with each other"

# Print instance details
echo "Master node 1 instance ID: $master_instance_id"
echo "Worker node 1 instance ID: $worker1_instance_id"
echo "Worker node 2 instance ID: $worker2_instance_id"

echo "Setup completed successfully!"

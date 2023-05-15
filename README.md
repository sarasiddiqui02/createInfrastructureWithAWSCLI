# linuxServersonAWSScript

bash shell script(s) that leverages the AWS CLI tool to create the following cloud architecture and set up:
All resources to be in us-east-1
VPC
Internet gateway
Internet gateway attached to VPC
Public subnet
Enable auto-assign public IP on public subnet
Public route table for pubilc subnet
Route table has a routing rule to internet gateway
Associate the public subnet with the public route table
EC2 instances
Master node 1
Size: t2.small
Image: Ubuntu 20.04
Installed software
Python 3.10
Node 18.0
Java 11.0
Docker engine
Tag
key=Name ,value=master-node-01
Worker node 1
Size: t2.micro
Image: Ubuntu 20.04
Installed software
Python 3.10
Node 18.0
Java 11.0
Docker engine
Tag
key=Name ,value=worker-node-01
Worker node 2
Size: t2.micro
Image: Ubuntu 20.04
Installed software
Python 3.10
Node 18.0
Java 11.0
Docker engine
Tag
key=Name ,value=worker-node-02
All three EC2 instances are
In the same public subnet and VPC,
Are reachable to each other - e.g. via the ping command
Are accessible remotely by SSH
All resources created are tagged
key=project ,value=wecloud

# vpc.tf 

provider "aws" {
  version = "~> 2.0"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
# create the VPC
resource "aws_vpc" "VPC" {
  cidr_block           = "${var.vpcCIDRblock}"
  instance_tenancy     = "${var.instanceTenancy}"
  enable_dns_support   = "${var.dnsSupport}" 
  enable_dns_hostnames = "${var.dnsHostNames}"
tags = {
    Name = "VPC"
}
} # end resource
# create the Subnet
resource "aws_subnet" "Public_subnet1" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.subnetCIDRblock1}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
  availability_zone       = "${var.availabilityZone1}"
tags = {
   Name = "Public_Subnet1"
}
}
resource "aws_subnet" "Public_subnet2" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.subnetCIDRblock2}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
  availability_zone       = "${var.availabilityZone2}"
tags = {
   Name = "Public_Subnet2"
}
}
resource "aws_subnet" "Private_subnet1" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.subnetCIDRblock3}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
  availability_zone       = "${var.availabilityZone1}"
tags = {
   Name = "Private_subnet1"
}
}
resource "aws_subnet" "Private_subnet3" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.subnetCIDRblock4}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
  availability_zone       = "${var.availabilityZone1}"
  #default_for_az          = "true"
tags = {
   Name = "Private_subnet3"
   #Purpose = "Default subnet for ap-south-1a"
}
}
resource "aws_subnet" "Private_subnet2" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.subnetCIDRblock5}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
  availability_zone       = "${var.availabilityZone2}"
tags = {
   Name = "Private_subnet2"
}
}
resource "aws_subnet" "Private_subnet4" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.subnetCIDRblock6}"
  map_public_ip_on_launch = "${var.mapPublicIP}" 
  availability_zone       = "${var.availabilityZone2}"
  #default_for_az          = "true"
tags = {
  Name = "Private_subnet4"
}
}
resource "aws_default_subnet" "def_subnet" {
    availability_zone = "ap-south-1a"
}

# Create the Security Group
resource "aws_security_group" "VPC_Security_Group" {
  vpc_id       = "${aws_vpc.VPC.id}"
  name         = "VPC Security Group"
  description  = "VPC Security Group"

  # allow ingress of port 80
  ingress {
    cidr_blocks = "${var.ingressCIDRblock}"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  # allow ingress of port 443 
  ingress {
    cidr_blocks = "${var.ingressCIDRblock}" 
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  } 
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "VPC Security Group"
   Description = "VPC Security Group"
}
} # end resource
#Jumpbox creation
resource "aws_instance" "Jumpbox" {
  ami           = "ami-005956c5f0f757d37"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.Public_subnet1.id}"
  tags = {
   Name = "Jumpbox"
}
}
resource "aws_instance" "NgnixOFBiz1" {
  ami           = "ami-005956c5f0f757d37"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.Private_subnet1.id}"
  tags = {
   Name = "NgnixOFBiz"
   Purpose = "App Server"
}
}
resource "aws_ebs_volume" "appserver_appdisk" {
  availability_zone = "${var.availabilityZone1}"
  size              = 25
}
resource "aws_volume_attachment" "ebs_att_appserver" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.appserver_appdisk.id}"
  instance_id = "${aws_instance.NgnixOFBiz1.id}"
}
resource "aws_instance" "NgnixOFBiz2" {
  ami           = "ami-005956c5f0f757d37"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.Private_subnet2.id}"
  tags = {
   Name = "NgnixOFBiz"
   Purpose = "Reporting Server"
}
}
resource "aws_ebs_volume" "reportingserver_appdisk" {
  availability_zone = "${var.availabilityZone2}"
  size              = 25
}
resource "aws_volume_attachment" "ebs_att_reportingserver" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.reportingserver_appdisk.id}"
  instance_id = "${aws_instance.NgnixOFBiz2.id}"
}

resource "aws_rds_cluster" "applicationcluster" {
  cluster_identifier = "applicationpostgres-cluster"
  availability_zones = ["${var.availabilityZone1}", "${var.availabilityZone2}"]
  database_name      = "masterdb"
  master_username    = "root"
  master_password    = "OFBiz@123"
  replication_source_identifier = "true"
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "applicationpostgres-cluster-${count.index}"
  cluster_identifier = "${aws_rds_cluster.applicationcluster.id}"
  instance_class     = "db.t2.micro"
  engine               = "aurora-postgresql"
  engine_version       = "9.6.3"
  #allocated_storage    = 25
}

# Create the Internet Gateway
resource "aws_internet_gateway" "VPC_GW" {
 vpc_id = "${aws_vpc.VPC.id}"
 tags = {
        Name = "My VPC Internet Gateway"
}
} # end resource
# Create the Route Table
resource "aws_route_table" "VPC_route_table" {
 vpc_id = "${aws_vpc.VPC.id}"
 tags = {
        Name = "My VPC Route Table"
}
} # end resource
resource "aws_route_table" "nat_private_table" {
 vpc_id = "${aws_vpc.VPC.id}"
 tags = {
        Name = "Private_subnets_route table"
}
}
resource "aws_route" "nat_internet_access" {
  route_table_id         = "${aws_route_table.nat_private_table.id}"
  destination_cidr_block = "${var.destinationCIDRblock}"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
}
# Create the Internet Access
resource "aws_route" "VPC_internet_access" {
  route_table_id         = "${aws_route_table.VPC_route_table.id}"
  destination_cidr_block = "${var.destinationCIDRblock}"
  gateway_id             = "${aws_internet_gateway.VPC_GW.id}"
} # end resource
# Associate the Route Table with the Subnet
resource "aws_route_table_association" "VPC_association" {
  subnet_id      = "${aws_subnet.Public_subnet1.id}"
  route_table_id = "${aws_route_table.VPC_route_table.id}"
} # end resource

resource "aws_eip" "lb" {
  vpc      = true
}

#Creating the NAT Gateway and Adding to Route Table

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.lb.id}"
  subnet_id     = "${aws_subnet.Public_subnet2.id}"
tags = {
   Name = "VPC-NAT-GW"
}
}
resource "aws_route_table_association" "private_association" {
  subnet_id      = "${aws_subnet.Private_subnet1.id}"
  route_table_id = "${aws_route_table.nat_private_table.id}"
}

resource "aws_efs_file_system" "Application_EFS" {
  creation_token = "efs_file_system"

  tags = {
    Name = "ApplicationOFBiz_EFS"
  }
}

resource "aws_efs_mount_target" "Application_EFS_mount1" {
  file_system_id = "${aws_efs_file_system.Application_EFS.id}"
  subnet_id      = "${aws_subnet.Private_subnet1.id}"
}

resource "aws_efs_mount_target" "Application_EFS_mount2" {
  file_system_id = "${aws_efs_file_system.Application_EFS.id}"
  subnet_id      = "${aws_subnet.Private_subnet2.id}"
}
# end resource
#Creating ALB
resource "aws_lb" "VPC_alb" {
  name               = "VPC-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.VPC_Security_Group.id}"]
  subnets            = ["subnet-0c5d83311383a15f2","subnet-0043e9cf6f9b7df7a"]
}
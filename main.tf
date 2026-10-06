# ==============================================================================
# 1. DATA SOURCES
# ==============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==============================================================================
# 2. NETWORKING LAYER (VPC & SUBNETS)
# ==============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.environment}-public-subnet"
    Tier = "Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.environment}-private-subnet"
    Tier = "Private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ==============================================================================
# 3. SECURITY GROUPS (ZERO-TRUST HARDENING)
# ==============================================================================

# Web/Public Security Group
resource "aws_security_group" "public_sg" {
  name_prefix = "${var.environment}-public-sg-"
  description = "Public ingress firewall"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment}-public-sg"
  }
}

# Zero-Trust Private Security Group: ZERO INBOUND PORTS
resource "aws_security_group" "private_sg" {
  name_prefix = "${var.environment}-private-sg-"
  description = "Zero-trust firewall with no inbound ports"
  vpc_id      = aws_vpc.main.id

  # Egress required for SSM Agent to establish outbound TLS 443 tunnel to AWS
  egress {
    description = "Allow outbound HTTPS for AWS SSM APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment}-private-sg"
  }
}

# ==============================================================================
# 4. IAM ROLE & INSTANCE PROFILE FOR AWS SSM
# ==============================================================================
resource "aws_iam_role" "ssm_role" {
  name = "${var.environment}-ssm-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.environment}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

# ==============================================================================
# 5. COMPUTE LAYER (ZERO-TRUST DEMO INSTANCE)
# ==============================================================================

# SSH Key Pair (Kept for administrative break-glass option)
resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-deployer-key"
  public_key = file("~/.ssh/id_showcase.pub")
}

# Instance configured with SSM profile and ZERO open inbound ports.
# Placed in the public subnet so the pre-installed SSM agent can reach
# ssm.ap-south-1.amazonaws.com directly via IGW without paying for a NAT Gateway.
resource "aws_instance" "zero_trust_node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  key_name                    = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.environment}-zero-trust-ssm"
    Role = "AppServer"
  }
}
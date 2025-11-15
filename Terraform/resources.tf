resource "aws_vpc" "vfc_vpc" {
    cidr_block =  "10.0.0.0/16"

    tags = {
      Name = "vfc-vpc"
    }
}

resource "aws_subnet" "vfc_public_subnet_1a" {
    vpc_id = aws_vpc.vfc_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-west-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "vfc-public-subnet-1"
    }
}

resource "aws_subnet" "vfc_public_subnet_1c" {
    vpc_id = aws_vpc.vfc_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-1c"
    map_public_ip_on_launch = true

    tags = {
        Name = "vfc-public-subnet-2"
    }
}

resource "aws_internet_gateway" "vfc_internet_gateway" {
    vpc_id = aws_vpc.vfc_vpc.id

    tags = {
        Name = "vpc-igw"
    }
}

resource "aws_route_table" "vfc_rt_1a" {
    vpc_id = aws_vpc.vfc_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vfc_internet_gateway.id
    }

    tags = {
        Name = "vfc-rt"
    }
}

resource "aws_route_table_association" "subnet1a_association" {
    subnet_id = aws_subnet.vfc_public_subnet_1a.id
    route_table_id = aws_route_table.vfc_rt_1a.id
}

resource "aws_route_table_association" "subnet1c_association" {
    subnet_id = aws_subnet.vfc_public_subnet_1c.id
    route_table_id = aws_route_table.vfc_rt_1a.id
}

resource "aws_instance" "vfc_instance_1a" {
    ami = data.aws_ami.ubuntu_ami.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.vfc_public_subnet_1a.id
    vpc_security_group_ids = [aws_security_group.webservers_sg.id]
    associate_public_ip_address = true
    key_name = data.aws_key_pair.existing_vfc_key.key_name

    tags = {
        Name = "vfc-webserver"
        role = "webserver"
    }
}

resource "aws_instance" "vfc_instance_1c" {
    ami = data.aws_ami.ubuntu_ami.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.vfc_public_subnet_1c.id
    vpc_security_group_ids = [aws_security_group.databases_sg.id]
    associate_public_ip_address = true
    key_name = data.aws_key_pair.existing_vfc_key.key_name

    tags = {
        Name = "vfc-dbserver"
        role = "db"
    }
}

resource "aws_security_group" "webservers_sg" {
    name = "vfc-web-sg"
    vpc_id = aws_vpc.vfc_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "databases_sg" {
    name = "vfc-db-sg"
    vpc_id = aws_vpc.vfc_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.webservers_sg.id] # Restricting to webservers
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


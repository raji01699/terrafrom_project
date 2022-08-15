provider "aws" {

region = "us-east-1"

access_key = "ASIAQKNNND3H37CE2QK5"

secret_key = "tHs8jxODcBspcgeePh+oGXUJ0cIesae5MmcPCuY2"

token = "FwoGZXIvYXdzEGMaDB23Ul2Z37k7B/dPJCK0AUj1JoSrNRs+ciI9uz9+LqYeMe1smOVOqPJYxSjSbOO9WoqG2ltswj42fLWJdm8ICo6rG67G8T0E1W+hD6dNm0OgDAs7cmJ1nkbsgnWprRWL1TXNbgHUeEEshut4z8Jhui1eWO64zTHCDaqM0KjfNxLxgCxRcaCFCzLTOi1Rn53d9YYLl2bMfoYHdSZU1JzhBQ0sEPwQ9SwZ1U/fE8uqypSqcodbznNfqR1LbeDPAQzjyUV1zijmsuiXBjItsaJezKQxtZvnuavRjl9a5efqMjY5HeTOXQFz+DhkzLmAj/S7h8KLC0c/5xrB"

}

# Security group settings

variable "ingress-rules" {

type = list(number)

default = [22, 8080]

}

resource "aws_security_group" "web_traffic" {

name = "Allow web traffic"

description = "SSH/Jenkins inbound, everything outbound"

dynamic "ingress" {

iterator = port

for_each = var.ingress-rules

content {

from_port = port.value

to_port = port.value

protocol = "TCP"

cidr_blocks = ["0.0.0.0/0"]

}

}

egress {

from_port = 0

to_port = 0

protocol = "-1"

cidr_blocks = ["0.0.0.0/0"]

}

}


# Type of resource to be executed

resource "aws_instance" "ec2" {

ami = "ami-04505e74c0741db8d"
# ami =  "ami-2757f631"
#ami = "ami-085141900928"

instance_type = "t3.micro"

key_name = "my_key_pair"

vpc_security_group_ids = [aws_security_group.web_traffic.id]

# Remotely execute commands to install Java, Python, Jenkins

provisioner "remote-exec" {

inline = [

"sudo apt update && upgrade",

"sudo apt install -y python3.8",

"wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",

"sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",

"sudo apt-get update",

"sudo apt-get install -y openjdk-8-jre",

"sudo apt-get install -y jenkins",

]

}

# Type of connection to be established

connection {

type = "ssh"

user = "ubuntu"

private_key = file("${path.module}/my_key_pair.pem")

host = self.public_ip

}

}

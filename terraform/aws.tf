provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-west-2"
} 

resource "aws_key_pair" "example" {
  key_name    = "aws_key"
  public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDiHVHSjUOHYPhWv5+COXFzCmgruQ0XuvVs0veVtNpy6u5ktUSn7O+mQSbtXsElTKm57ost5Jb/fZIXHC8sQZT96zIPld3rQqmPQcPDSX2dY9l/vUDFag3OY14jsqRc+eFbkb7dtLTVZITqIHPVN2AhIXZaz8Z2prINOlXm+qYlROPHiITDmMzia6SW2oHi5q2PN9iq+f5c3+HwT7aapuWURm8wfELR7NzfUVX1EVv9WAU5Q6fKbhAnzQ/PofaifQzk5EMuNyXfUmtsQg0yfahpqvmPSMgTe3e6/AAbdaFplfdUFoOFSFTUTGDrX86KWBaSdn5LmSKslpKrzEAvKhxtpq200mwI3p24Ms4eY3LCHNNudKugr6ZeU+F7CXXGxPY3KfMODOEA1FbD68OUJPG0yvCd/l6O92Fi5cGZaKoR8d6IbKRFVjEDejKCr2zo2CZfaLxK31B7P4wjkpdUse05gahleS3civaDrrzFSmow/RIWMsULfE9je8LZGWHuWC3feeRToA90DfEVvrzR572d/Z8ei73LDEHS0M2h01ykUWa8cFlgRh/UpI+7R/cK+Sy3N89D1/f6stryUPoRCHCCI3TqviAWH90rA/iGmw7+YF9UZvNkPFh3n80IdC31a4HBX0e4aEflZh77WU6A8WnlPYA+L7gU82eHihcIcUIh6Q== wyman.lucy@gmail.com"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

variable "instances" {
  default   = 2
}

variable "access_key" {}
variable "secret_key" {}

resource "aws_instance" "centos" {
  count             = "${var.instances}"
  ami               = "ami-fe5efb9e"
  instance_type     = "t2.micro"
  key_name          = "aws_key"
  security_groups   = ["allow_all"]
}

output "public_ips" {
  value = "${aws_instance.centos.*.public_ip}"
}
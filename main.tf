data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "YtseJam"
    workspaces = {
      name = "canary-rolling"
    }

  }
}

provider "aws" {
  region = data.terraform_remote_state.network.outputs.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "blue" {
  count = var.enable_blue_env ? var.blue_instance_count : 0

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnets[count.index % length(data.terraform_remote_state.network.outputs.public_subnets)]
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.web_sg_id]
  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "version 1.0 - #${count.index}"
  })

  tags = {
    Name = "version-1.0-${count.index}"
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  count            = length(aws_instance.blue)
  target_group_arn = data.terraform_remote_state.network.outputs.tg_blue_arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}

resource "aws_instance" "green" {
  count = var.enable_blue_env ? var.blue_instance_count : 0

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnets[count.index % length(data.terraform_remote_state.network.outputs.public_subnets)]
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.web_sg_id]
  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "version 1.1 - #${count.index}"
  })

  tags = {
    Name = "green-${count.index}"
  }
}

resource "aws_lb_target_group_attachment" "green" {
  count            = length(aws_instance.green)
  target_group_arn = data.terraform_remote_state.network.outputs.tg_green_arn
  target_id        = aws_instance.green[count.index].id
  port             = 80
}
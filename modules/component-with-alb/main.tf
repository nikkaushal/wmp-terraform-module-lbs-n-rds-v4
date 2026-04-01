resource "aws_security_group" "instance" {

  name = "${var.component}-${var.env}-instance"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.component}-${var.env}-instance"
  }
}
resource "aws_security_group" "alb" {

  name = "${var.component}-${var.env}-alb"

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.component}-${var.env}-alb"
  }
}

resource "aws_launch_template" "main" {
  name                   = "${var.component}-${var.env}-"
  image_id               = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id, aws_security_group.alb.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh",
    {
      ENV       = var.env,
      COMPONENT = var.component
      postgres_rds_address = var.postgres_rds_address
    }
  ))
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.component}-${var.env}"
    }
  }
}


resource "aws_autoscaling_group" "main" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  name               = "${var.component}-${var.env}"
  max_size           = var.asg["max_size"]
  min_size           = var.asg["min_size"]
  desired_capacity   = var.asg["min_size"]
  target_group_arns  = [aws_lb_target_group.main.arn]
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.component}-${var.env}"
  port     = var.lb["port"]
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 2
    matcher             = "200,403"
  }

}
resource "aws_lb" "main" {
  name               = "${var.component}-${var.env}"
  internal           = var.lb["lb_internal"]
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnets
  tags = {
    Name = "${var.component}-${var.env}"
  }

}

resource "aws_lb_listener" "front-end" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.lb["port"]
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

}
resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.component}-${var.env}.${var.dns_domain}"
  type    = "CNAME"
  ttl     = 30
  records = [aws_lb.main.dns_name]
}

# resource "null_resource" "ansible" {

#   provisioner "remote-exec" {
#     connection {
#       type     = "ssh"
#       host     = aws_instance.main.private_ip
#       user     = "ec2-user"
#       password = "DevOps321"
#     }
#     inline = [
#       "sudo labauto ansible",
#       "ansible-pull -i localhost, -U https://github.com/nikkaushal/wmp-ansible-templates-v3.git main.yml -e env=${var.env} -e COMPONENT=${var.component}"
#     ]
#   }
# } 

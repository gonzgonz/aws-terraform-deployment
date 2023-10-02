resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB HTTP access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Access From Everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "cint_infrastructure" {
  name               = "cint-infrastructure-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = aws_subnet.public[*].id

  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_security_group" "handle_sg" {
  name        = "handle-sg"
  description = "Security group for handle access"
  vpc_id      = aws_vpc.main.id


  ingress {
    description     = "Access from attached resources"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb_listener" "cint_infrastructure_listener" {
  load_balancer_arn = aws_lb.cint_infrastructure.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cint_infrastructure.arn
  }
}

resource "aws_launch_template" "cint_infrastructure" {
  name_prefix            = "cint-infrastructure"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.nano"
  vpc_security_group_ids = [aws_security_group.handle_sg.id]

  /*
  This is a basic way of making sure the boostrapped instances will have the Database endpoint
  available as a system (environment) variable. Amazon SSM is another way of achieving this instead, but choosing this for simplicity here.

  We're also going to install and run nginx so that something is available at port 80
  To be honest this could probably be Docker and ECS or EKS instead, but for the sake of this project I'm sticking to this.
  */
  user_data = base64encode(<<EOF
    #!/bin/bash
    echo "export RDS_DNS_ENDPOINT=${aws_db_instance.rds_instance.endpoint}" >> /etc/profile
    source /etc/profile
    yum update -y
    amazon-linux-extras install nginx1.12 -y
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}

resource "aws_lb_target_group" "cint_infrastructure" {
  name     = "cint-infrastructure-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

resource "aws_autoscaling_group" "cint_infrastructure" {
  name             = "cint-infrastructure-webserver-asg"
  min_size         = 1
  max_size         = 4
  desired_capacity = 2
  launch_template {
    id      = aws_launch_template.cint_infrastructure.id
    version = "$Latest"
  }

  vpc_zone_identifier       = aws_subnet.private[*].id
  target_group_arns         = [aws_lb_target_group.cint_infrastructure.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "ScaleOut"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.cint_infrastructure.name
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "ScaleIn"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.cint_infrastructure.name
  scaling_adjustment     = -1
  cooldown               = 300
}



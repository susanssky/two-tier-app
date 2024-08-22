resource "aws_ami_from_instance" "create_image" {
  depends_on         = [aws_ssm_association.log_s3, aws_instance.backend]
  name               = "${local.project_name}-ec2-image"
  source_instance_id = aws_instance.backend.id
}


resource "aws_launch_template" "ec2-template" {
  image_id      = aws_ami_from_instance.create_image.id
  instance_type = "t2.micro"
  # key_name      = aws_key_pair.ssh_key.key_name

  # monitoring {
  #   enabled = true
  # }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  tags = {
    Name = "${local.project_name}-template"
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "auto-scaling-${local.project_name}-ec2"
    }
  }

}

resource "aws_autoscaling_group" "autoscaling-group" {
  vpc_zone_identifier = [for id in aws_subnet.public[*].id : id]
  desired_capacity    = 2
  min_size            = 2
  max_size            = 6
  force_delete        = true
  target_group_arns   = aws_lb_target_group.lb-target-group[*].arn

  launch_template {
    id      = aws_launch_template.ec2-template.id
    version = "$Latest"
  }
}
# including ec2 alarm
resource "aws_autoscaling_policy" "autoscaling-policy" {
  name        = "${local.project_name}-scaling-target-tracking-policy"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
  autoscaling_group_name = aws_autoscaling_group.autoscaling-group.name
}

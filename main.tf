provider "aws" {
  region = "ap-south-1"
}

resource "aws_launch_configuration" "ashish_lc" {
  name = "ashish-config"
  image_id = "ami-0a7cf821b91bcccbc" # ubuntu-image
  instance_type = "t2.micro"
  key_name = "my-assignment-key"
  iam_instance_profile = "custom-metrcis-role" # role with required set of permissions for ASG
  user_data = filebase64("script.sh")
}



resource "aws_autoscaling_group" "ashish_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier = ["subnet-abcxxxxxxx"] # subnet ID 
  launch_configuration = aws_launch_configuration.ashish_lc.id

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete               = true
  tag {
    key                 = "Name"
    value               = "ashish-asg"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "load" # custom metrics for load average
  namespace           = "ServerLoad" 
  period              = 60
  statistic           = "Average"
  threshold           = 0.75
  alarm_description   = "Scale up when load average exceeds 75%"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.scale_up_policy.arn}", "${aws_sns_topic.email_alerts.arn}"]
  dimensions = {
    ASG = aws_autoscaling_group.ashish_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  scaling_adjustment    = 1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.ashish_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "load" # custom metrics for load average
  namespace           = "ServerLoad"
  period              = 60  
  statistic           = "Average"
  threshold           = 0.50
  alarm_description   = "Scale down when load average is below 50%"
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.scale_down_policy.arn}", "${aws_sns_topic.email_alerts.arn}"]
  dimensions = {
    ASG = aws_autoscaling_group.ashish_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  scaling_adjustment    = -1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.ashish_asg.name
}

resource "aws_autoscaling_policy" "scale_up_instance_policy" {
  name                   = "scale-up-instance-policy"
  scaling_adjustment    = 1
  adjustment_type       = "ExactCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.ashish_asg.name
}

resource "aws_autoscaling_policy" "scale_down_instance_policy" {
  name                   = "scale-down-instance-policy"
  scaling_adjustment    = -1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.ashish_asg.name
}

resource "aws_autoscaling_schedule" "daily_refresh" {
  scheduled_action_name = "daily-refresh"
  min_size              = 0
  desired_capacity     = 0
  max_size              = 0
  start_time            = "2024-01-21T00:00:00Z"  # UTC 12am every day. Change it to future date otherwise it will fail.
  recurrence            = "0 0 * * *"
  autoscaling_group_name = aws_autoscaling_group.ashish_asg.name
}

# Define AWS SNS Topic for sending email alerts
resource "aws_sns_topic" "email_alerts" {
  name = "scale-email-alerts"
}

# Define AWS SNS Subscription to send emails
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.email_alerts.arn
  protocol  = "email"
  endpoint  = "ashisharun7@gmail.com" # add your email and subscribe for confirmation
}

resource "aws_instance" "instance1" {
  count = var.instance_count
  ami = "ami-090fa75af13c156b4"
  instance_type = "t2.micro"
  
    security_groups = [
    var.sec_group_name,
  ]
  vpc_security_group_ids = [
    aws_security_group.instance.id,
  ]
  root_block_device {
    volume_size = var.volume_size
  }
  
  tags={
    Name= "instance-${count.index}"
  }
}
resource "aws_cloudwatch_metric_alarm" "disk_percentage_low" {
  for_each                  = toset(var.instance)
  alarm_name                = "disk_percentage_low"  
  comparison_operator       = "LessThanOrEqualToThreshold"  
  evaluation_periods        = "1"                  
  metric_name               = "LogicalDisk % Free Space"
  namespace                 = "AWS/EC2"  
  period                    = "60"   
  statistic                 = "Average"            
  threshold                 = "20"
  alarm_description         = "This metric monitors ec2 disk utilization"   
  actions_enabled           = "true"    
  #alarm_actions             = [aws_sns_topic.disk_alarm.arn]   
  insufficient_data_actions = []
  
  dimensions = {
    InstanceId   = "i-0c4b0314e50652017"
    InstanceType = "t2.micro"
    instance     = each.value
             } 
}

resource "aws_security_group" "instance" {
  description = var.sec_group_description
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = ""
      from_port = 0
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "-1"
      security_groups = []
      self = false
      to_port = 0
    },
  ]
  ingress = [
    for _port in var.port_list:
    {
      cidr_blocks = [
      for _ip in var.ip_list:
      _ip
      ]
      description = ""
      from_port = _port
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "tcp"
      security_groups = []
      self = false
      to_port = _port
    }
  ]
  name = var.sec_group_name
} 
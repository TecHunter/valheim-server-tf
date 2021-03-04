resource "aws_ecs_service" "ecs-service" {
  name            = "${var.appname}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1 # only one docker supported

   network_configuration {
    subnets          = aws_subnet.default_subnet[*].id
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each= var.ports
    content{ 
        target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
        container_name   = aws_ecs_task_definition.app-task.family
        container_port   = load_balancer.value[0]
    }
  }

   tags = {
    Application  = var.appname
  }
}

resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Application  = var.appname
  }
}

resource "aws_subnet" "default_subnet" {
  count = length(var.subnet_zones)

  vpc_id            = aws_vpc.default_vpc.id
  availability_zone = var.subnet_zones[count.index]
  cidr_block        = cidrsubnet(aws_vpc.default_vpc.cidr_block, 8, count.index + 1)
  tags = {
    Application  = var.appname
  }
}

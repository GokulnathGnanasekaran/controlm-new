
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.eu-west-1.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.em_subnet_ids
  security_group_ids = [aws_security_group.security.id]
  tags               = merge(map("Name", "com.amazonaws.eu-west-1.ssm", "Description", "Endpoint for Control-M - SSM"), local.tags)
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.eu-west-1.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.em_subnet_ids
  security_group_ids = [aws_security_group.security.id]
  tags               = merge(map("Name", "com.amazonaws.eu-west-1.ssmmessages", "Description", "Endpoint for Control-M - SSM Messages"), local.tags)
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.eu-west-1.ec2"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.em_subnet_ids
  security_group_ids = [aws_security_group.security.id]
  tags               = merge(map("Name", "com.amazonaws.eu-west-1.ec2", "Description", "Endpoint for Control-M - EC2"), local.tags)
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.eu-west-1.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.em_subnet_ids
  security_group_ids = [aws_security_group.security.id]
  tags               = merge(map("Name", "com.amazonaws.eu-west-1.ec2messages", "Description", "Endpoint for Control-M - EC2 Messages"), local.tags)
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.eu-west-1.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.em_subnet_ids
  security_group_ids = [aws_security_group.security.id]
  tags               = merge(map("Name", "com.amazonaws.eu-west-1.logs", "Description", "Endpoint for Control-M - Logs"), local.tags)
}

resource "aws_vpc_endpoint" "elb" {
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.eu-west-1.elasticloadbalancing"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.em_subnet_ids
  security_group_ids = [aws_security_group.security.id]
  tags               = merge(map("Name", "com.amazonaws.eu-west-1.elasticloadbalancing", "Description", "Endpoint for Control-M - ELB"), local.tags)
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.routetable_ids
  auto_accept       = true
  tags              = merge(map("Name", "com.amazonaws.eu-west-1.s3", "Description", "Endpoint for Control-M - S3"), local.tags)
}

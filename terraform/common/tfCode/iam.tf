data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name                 = "eu-west-1_js_roles_ctm_instance"
  path                 = "/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ccoe/js-developer"
  assume_role_policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
  tags = merge(
    {
      "Name"        = "JS_ControlM-IAM_Instance_Role"
      "Description" = "ControlM IAM Instance Role"
    },
    local.tags,
  )
}

resource "aws_iam_policy" "policy" {
  name        = "${module.vars.project}-IAM_Policy"
  path        = "/"
  description = "IAM policy for Control-M"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ssm:ListInstanceAssociations",
                "ssm:GetDeployablePatchSnapshotForInstance"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
       {
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::js-software-files/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::aws-ssm-eu-west-1/*",
                "arn:aws:s3:::amazon-ssm-eu-west-1/*",
                "arn:aws:s3:::amazon-ssm-packages-eu-west-1/*",
                "arn:aws:s3:::patch-baseline-snapshot-eu-west-1/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": "ssm:GetDocument",
            "Resource": "arn:aws:ssm:eu-west-1::document/AWS-GatherSoftwareInventory",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:PutInventory",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssmmessages:*",
                "ec2messages:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": [
                "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*",
                "arn:aws:ssm:*:*:parameter/ctm*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "s3readonly" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "profile" {
  name = "eu-west-1-js_instanceprofile_ctm"
  role = aws_iam_role.role.name
}

# Create role for c7n-lambda-role

resource "aws_iam_role" "c7n_lambda_role" {
  name                 = "c7n-lambda-role"
  path                 = "/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ccoe/js-developer"
  assume_role_policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
  tags = merge(
    {
      "Name"        = "c7n-lambda-role"
      "Description" = "ControlM c7n Lambda Role"
    },
    local.tags,
  )
}

resource "aws_iam_policy" "c7n_lambda_policy" {
  name        = "${module.vars.project}-C7N_Lambda_Policy"
  path        = "/"
  description = "IAM policy for C7N Lambda"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "sqs:SendMessage",
                "iam:ListAccountAliases"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "c7n_policy" {
  role       = aws_iam_role.c7n_lambda_role.name
  policy_arn = aws_iam_policy.c7n_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2fullaccess" {
  role       = aws_iam_role.c7n_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambdaexecution" {
  role       = aws_iam_role.c7n_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

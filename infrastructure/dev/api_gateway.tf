data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "incident-app-team-a" {
  name = "incident-app-team-a"
}

resource "aws_iam_role_policy_attachment" "dynamodb-lambda" {
  role       = "${element(split("/",var.apex_function_role), 1)}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy" "kms-lambda-policy" {
  name        = "kms-lambda-policy"
  description = "kms policy for lambda function"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:CreateAlias",
                "kms:CreateKey",
                "kms:DisableKey",
                "kms:DeleteAlias",
                "kms:Describe*",
                "kms:DescribeKey",
                "kms:EnableKey",
                "kms:Encrypt",
                "kms:GenerateRandom",
                "kms:Get*",
                "kms:List*",
                "kms:ScheduleKeyDeletion",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:UpdateKeyDescription",
                "iam:ListGroups",
                "iam:ListRoles",
                "iam:ListUsers"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kms-lambda" {
  role       = "${element(split("/",var.apex_function_role), 1)}"
  policy_arn = "${aws_iam_policy.kms-lambda-policy.arn}"
}

resource "aws_kms_key" "plivo" {
  description = "plivo kms key"
  is_enabled  = true
}

resource "aws_kms_alias" "plivo_alias" {
  name = "alias/lambda-plivo"
  target_key_id  = "${aws_kms_key.plivo.key_id}"
}

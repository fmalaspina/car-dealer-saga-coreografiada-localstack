terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region                      = var.region
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    sns = var.endpoint
    sqs = var.endpoint
    iam = var.endpoint
    sts = var.endpoint
  }
}


# SNS topic
resource "aws_sns_topic" "car_events" {
  name = "car-events"
}

# SQS queues
resource "aws_sqs_queue" "orders" {
  name = "orders"
}

resource "aws_sqs_queue" "inventory" {
  name = "inventory"
}

resource "aws_sqs_queue" "billing" {
  name = "billing"
}

resource "aws_sqs_queue" "contracts" {
  name = "contracts"
}

# Subscriptions SNS -> SQS
resource "aws_sns_topic_subscription" "orders" {
  topic_arn = aws_sns_topic.car_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.orders.arn
}

resource "aws_sns_topic_subscription" "inventory" {
  topic_arn = aws_sns_topic.car_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.inventory.arn
}

resource "aws_sns_topic_subscription" "billing" {
  topic_arn = aws_sns_topic.car_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.billing.arn
}

resource "aws_sns_topic_subscription" "contracts" {
  topic_arn = aws_sns_topic.car_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.contracts.arn
}

# Allow SNS to send to these SQS queues (for IAM enforcement)
data "aws_iam_policy_document" "sns_to_sqs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = ["sqs:SendMessage"]

    resources = [
      aws_sqs_queue.orders.arn,
      aws_sqs_queue.inventory.arn,
      aws_sqs_queue.billing.arn,
      aws_sqs_queue.contracts.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.car_events.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "orders" {
  queue_url = aws_sqs_queue.orders.id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

resource "aws_sqs_queue_policy" "inventory" {
  queue_url = aws_sqs_queue.inventory.id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

resource "aws_sqs_queue_policy" "billing" {
  queue_url = aws_sqs_queue.billing.id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

resource "aws_sqs_queue_policy" "contracts" {
  queue_url = aws_sqs_queue.contracts.id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

# IAM user + access keys for apps
resource "aws_iam_user" "app_user" {
  name = "car_dealer_app"
}

resource "aws_iam_access_key" "app_key" {
  user = aws_iam_user.app_user.name
}

data "aws_iam_policy_document" "app_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:ListTopics"
    ]
    resources = [aws_sns_topic.car_events.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [
      aws_sqs_queue.orders.arn,
      aws_sqs_queue.inventory.arn,
      aws_sqs_queue.billing.arn,
      aws_sqs_queue.contracts.arn
    ]
  }
}

resource "aws_iam_policy" "app_policy" {
  name   = "car_dealer_app_policy"
  policy = data.aws_iam_policy_document.app_policy.json
}

resource "aws_iam_user_policy_attachment" "attach" {
  user       = aws_iam_user.app_user.name
  policy_arn = aws_iam_policy.app_policy.arn
}

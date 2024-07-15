locals {
  sns_topic_name = "approve-topic-${random_pet.name.id}"
}
resource "aws_sns_topic" "sns_topic" {
  name         = local.sns_topic_name
  display_name = "Approver Topic"
  tags         = merge(var.tags, { Name = local.sns_topic_name })
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "SNS_topic_policy"
  ## Self Access
  statement {
    sid    = "allow_from_self"
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    resources = [
      aws_sns_topic.sns_topic.arn
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }

  ## Enforce encryption of data in transit
  statement {
    sid    = "AllowPublishThroughSSLOnly"
    effect = "Deny"
    actions = [
      "SNS:Publish"
    ]
    resources = [
      aws_sns_topic.sns_topic.arn
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}



resource "aws_sns_topic_subscription" "default" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.subscriber_email_address
}
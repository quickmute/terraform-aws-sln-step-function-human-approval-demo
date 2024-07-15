## Your S3 Bucket for this demo
resource "aws_s3_bucket" "example" {
  bucket = local.bucket_name
  tags = merge(
    var.tags,
    {
      "Name" = local.bucket_name
    }
  )
  force_destroy = true
}

## Make this website enabled bucket
## AWS Provider 4.0.0 code
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

## Remove unneeded public access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## Only allow from your testing machine
data "aws_iam_policy_document" "allow_from_my_machine" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.example.arn}/*"
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = [
        var.myip
      ]
    }

  }
}

## Attach the bucket policy
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.allow_from_my_machine.json
}

## Existing files shall be overwritten
resource "local_file" "foo" {
  content  = <<EOF
window._config = {
    api: {
        invokeUrl: "${local.invoke_url}"
    }
};
EOF
  filename = "${path.module}/s3/js/config.js"
}

## This doesn't really need to be here except to demonstrate how to do a sleep
resource "time_sleep" "wait_30_seconds" {
  depends_on      = [local_file.foo]
  create_duration = "30s"
}

locals {
  s3_path = "${path.module}/s3"
}

##Upload all files to S3
##Another AWS Provider 4.0.0 resource
resource "aws_s3_object" "object" {
  for_each     = fileset(local.s3_path, "**")
  bucket       = aws_s3_bucket.example.id
  key          = each.key
  source       = join("/", [local.s3_path, each.key])
  etag         = filemd5(join("/", [local.s3_path, each.key]))
  content_type = "text/html"
  depends_on = [
    time_sleep.wait_30_seconds
  ]
}

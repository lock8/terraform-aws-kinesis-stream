resource "aws_kinesis_stream" "this" {

  name                      = var.name
  shard_count               = var.shard_count
  retention_period          = var.retention_period
  shard_level_metrics       = var.shard_level_metrics
  enforce_consumer_deletion = var.enforce_consumer_deletion
  encryption_type           = var.encryption_type
  kms_key_id                = var.kms_key_id
  tags                      = var.tags

  stream_mode_details {
      stream_mode = var.shard_count == null ? "ON_DEMAND" : "PROVISIONED"
  }

}

resource "aws_iam_policy" "read-only" {
  count = var.create_policy_read_only == true ? 1 : 0

  name        = format("kinesis-stream-%s-read-only", var.name)
  path        = "/"
  description = "Managed by Terraform"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeLimits",
          "kinesis:DescribeStream",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:SubscribeToShard",
          "kinesis:ListShards"
        ]
        Resource = [
          aws_kinesis_stream.this.arn
        ]
      }
    ])
  })
}

resource "aws_iam_policy" "write-only" {
  count = var.create_policy_write_only == true ? 1 : 0

  name        = format("kinesis-stream-%s-write-only", var.name)
  path        = "/"
  description = "Managed by Terraform"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeStream",
          "kinesis:PutRecord",
          "kinesis:PutRecords",
        ]
        Resource = [
          aws_kinesis_stream.this.arn
        ]
      }
    ])
  })
}

resource "aws_iam_policy" "admin" {
  count = var.create_policy_admin == true ? 1 : 0

  name        = format("kinesis-stream-%s-admin", var.name)
  path        = "/"
  description = "Managed by Terraform"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "kinesis:*",
        ]
        Resource = [
          aws_kinesis_stream.this.arn
        ]
      }
    ])
  })
}

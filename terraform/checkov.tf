# resource "aws_flow_log" "example" {
#   log_destination      = aws_s3_bucket.example.arn
#   log_destination_type = "s3"
#   traffic_type         = "ALL"
#   vpc_id               = aws_vpc.cicddemo.id
# }

# resource "aws_s3_bucket" "example" {
#   bucket = "example"
# }

# resource "aws_s3_bucket_versioning" "versioning_example" {
#   bucket = aws_s3_bucket.example.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "example" {
#   bucket = aws_s3_bucket.example.id

#   rule {
#     id = "rule-1"

#     filter {}

#     abort_incomplete_multipart_upload {
#       days_after_initiation = 2
#     }

#     # ... other transition/expiration actions ...

#     status = "Enabled"
#   }
# }

# resource "aws_kms_key" "mykey" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
#   is_enabled              = true
#   enable_key_rotation     = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
#   bucket = aws_s3_bucket.example.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.mykey.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket = aws_s3_bucket.example.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

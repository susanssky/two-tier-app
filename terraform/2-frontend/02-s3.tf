resource "aws_s3_bucket" "frontend" {
  bucket        = local.project_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "frontend-control" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend-pab" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "policy" {
  depends_on = [aws_s3_bucket_ownership_controls.frontend-control, aws_s3_bucket_public_access_block.frontend-pab]
  bucket     = aws_s3_bucket.frontend.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.frontend.bucket}/*",
        "Condition" : {
          "StringEquals" : {
            "aws:UserAgent" : "${var.cloudfront-authentication-user-agent}"
          }
        }
      }
    ]
  })
}
module "template_files" {
  source   = "hashicorp/dir/template"
  base_dir = "../../app/client/dist"
}

resource "aws_s3_object" "frontend-object" {
  bucket       = aws_s3_bucket.frontend.id
  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

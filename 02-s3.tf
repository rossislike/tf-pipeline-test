resource "aws_s3_bucket" "website" {
  bucket        = "${var.project_name}-website-${local.suffix}-${var.env}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${local.suffix}-${var.env}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

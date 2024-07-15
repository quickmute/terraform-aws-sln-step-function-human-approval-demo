# Use this for your testing
# Default page won't display due to metadata not being plain/html (I think...)
output "website" {
  description = "the URL for your website"
  value       = join("/", ["http:/", aws_s3_bucket_website_configuration.example.website_endpoint, aws_s3_bucket_website_configuration.example.index_document[0].suffix])
}
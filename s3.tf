resource "aws_s3_bucket" "s3-bucket-a123c321" {
	bucket = "s3-bucket-a123c321"
	acl = "private"
	
	tags {
		Name = "s3-bucket-a123c321"
	}
}

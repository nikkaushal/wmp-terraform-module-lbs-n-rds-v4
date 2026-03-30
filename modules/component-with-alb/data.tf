data "aws_ami" "ami" {

  owners = ["973714476881"]

  filter {
    name   = "name"
    values = ["Redhat-9-DevOps-Practice"]
  }

}
data "aws_route53_zone" "main" {
  name = "tek-nik.com"
}
###############################################
# Terraform Outputs
###############################################
output "Terraform results" {
    value= "The following cloud instances were provisioned:"
}
output "Destination Region" {
    value = "${var.region_name}"
}
output "Instance CiviCRM Public DNS" {
    value = "${aws_instance.www.public_dns}"
}
output "Instance CiviCRM Public IP" {
    value = "${aws_instance.www.public_ip}"
}
output "Instance CiviCRM Private DNS" {
    value = "${aws_instance.www.private_dns}"
}
output "Instance CiviCRM Private IP" {
    value = "${aws_instance.www.private_ip}"
}
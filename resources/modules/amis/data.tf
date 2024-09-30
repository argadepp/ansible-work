data "aws_ssm_parameter" "bottlerocket_ami" {
  name = "/aws/service/bottlerocket/aws-k8s-${var.k8s_version}/x86_64/latest/image_id"
}

output "bottlerocketami" {
  value = data.aws_ssm_parameter.bottlerocket_ami.id
}
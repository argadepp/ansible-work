variable "region" {
  default = "ap-south-1"
}

variable "tags" {
  description = "A map of tags to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "The EC2 instance type"
}

variable "name" {
  description = "Instance name tag"
}

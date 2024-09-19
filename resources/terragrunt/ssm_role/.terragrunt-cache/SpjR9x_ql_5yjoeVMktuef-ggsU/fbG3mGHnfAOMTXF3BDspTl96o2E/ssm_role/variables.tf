variable "role_name" {
  
}

variable "policy_arn" {
  description = "The ARN of the policy to attach to the IAM role"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the instance"
  type        = map(string)
  default     = {}
}
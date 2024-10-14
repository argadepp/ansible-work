variable "bucket_name" {
  type = string
}

variable "tags" {
  description = "A map of tags to apply to the instance"
  type        = map(string)
  default     = {}
}
variable "subnet_ids" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "public_access_cidrs" {
  type    = list(string)
  default = [""]
}

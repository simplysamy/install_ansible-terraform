variable "instance_count" {
  type    = number
  default = 1
}

variable "ami_id" {
  type    = string
  default = "ami-06aa3f7caf3a30282"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "mtc-terransible"
}
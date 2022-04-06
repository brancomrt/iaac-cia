variable "subnet_cidr" {
  type = string
  default = "10.0.101.0/24"
}
variable "ami" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "var_public_key" {
  type = string
}

variable "shape_slacko" {
  type = string
}

variable "shape_mongodb" {
  type = string
}

variable "subnet_id" {
  type = string
}

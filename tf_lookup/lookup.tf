variable "env" {
    type = string
}

output "amabiente"{
    value = lookup(var.size, var.env)
}

variable "size" {
    type = map
    default = {
        "qa" = "Large",
        "dev" = "small"
        "prod" = "xLarge"
    }
}
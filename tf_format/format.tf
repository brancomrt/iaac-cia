variable "projetc" {
    type = string
}

variable "environment" {
    type = string
}

output "format_value" {
    value = format("%s_%s", var.project, var.environment)
}


variable "environment" {
  description = "ambiente"
  default     = "dev"
}

variable "lambda_name" {
  description = "nome da lambda"
  default     = "banyan-crm-lambda-opportunities"
}

variable "memory_size" {
  description = "memoria da lambda"
}
variable "environment" {
  description = "ambiente"
  default     = "dev"
}

variable "lambda_name" {
  description = "nome da lambda"
  default     = ""
}

variable "memory_size" {
  description = "memoria da lambda"
  default = 128
}
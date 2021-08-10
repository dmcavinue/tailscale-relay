
variable environment {
  description = "environment name"
  type        = string
}

variable tailscale_authkey {
  description = "tailscale authkey"
  type        = string
  sensitive   = true
}
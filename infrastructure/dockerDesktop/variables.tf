variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_username" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}
variable "cluster_name" {
  type = string
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "vpc_name" {
  type = string
  default = "itdev"
}

variable "terraform_state_s3_bucket" {
  type = string
  default = "dg-commercial-itdev-01-terraform-state"
}

variable "terraform_state_aws_region" {
  type = string
  default = "us-east-1"
}

variable "restricted_control_plane_az" {
  description = "Some availability zones in specific regions are known to lack support for EKS control planes. This list is used to mark those AZs where the control plane should not be deployed into."
  type        = list(string)

  default = [
    "us-east-1e",
  ]
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

# Worker Nodes
variable "desired_node_count" {
  type        = number
  default     = 3
}

variable "min_node_count" {
  type        = number
  default     = 3
}

variable "max_node_count" {
  type        = number
  default     = 5
}

variable "node_machine_type" {
  type         = string
  default      = "m5.large"
}


// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
variable "enable_logs_storage" {
  type        = bool
  default     = true
}

variable "enable_reports_storage" {
  type        = bool
  default     = true
}

variable "enable_repository_storage" {
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed. If set to false, empty the bucket first in the aws s3 console, else terraform destroy will fail with BucketNotEmpty error"
  type        = bool
  default     = false
}

variable "create_eks" {
  description = "Flag to skip EKS cluster creation and related resources."
  type        = bool
  default     = true
}

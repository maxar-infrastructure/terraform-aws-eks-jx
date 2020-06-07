// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "aws_region" {
  description = "The region to create the resources into"
  type        = string
  default     = "us-east-1"
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

variable "cluster_name" {
  description = "Variable to provide your desired name for the cluster. The script will create a random name if this is empty"
  type        = string
  default     = "jxboot"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.15"
}

// ----------------------------------------------------------------------------
variable "vault_user" {
  description = "The AWS IAM Username whose credentials will be used to authenticate the Vault pods against AWS"
  type        = string
  default     = "svc_eks_thundercats"
}

// ----------------------------------------------------------------------------
// Worker Nodes Variables
// ----------------------------------------------------------------------------
variable "desired_node_count" {
  description = "The number of worker nodes to use for the cluster"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "The minimum number of worker nodes to use for the cluster"
  type        = number
  default     = 3
}

variable "max_node_count" {
  description = "The maximum number of worker nodes to use for the cluster"
  type        = number
  default     = 5
}

variable "node_machine_type" {
  description = "The instance type to use for the cluster's worker nodes"
  type        = string
  default     = "m5.large"
}

// ----------------------------------------------------------------------------
// VPC Variables
// ----------------------------------------------------------------------------
variable "vpc_name" {
  description = "The name of the VPC to be created for the cluster"
  type        = string
  default     = "itdev"
}

# variable "vpc_subnets" {
#   description = "The subnet CIDR block to use in the created VPC"
#   type        = list(string)
#   default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# }

# variable "vpc_cidr_block" {
#   description = "The vpc CIDR block"
#   type        = string
#   default     = "10.0.0.0/16"
# }

// ----------------------------------------------------------------------------
// External DNS Variables
// ----------------------------------------------------------------------------
variable "apex_domain" {
  description = "The main domain to either use directly or to configure a subdomain from"
  type        = string
  default     = ""
}

variable "domain" {
  description = "The main domain to either use directly or to configure a subdomain from"
  type        = string
  default     = "jxboot.dg-commercial-itdev-01.satcloud.us"
}

variable "subdomain" {
  description = "The subdomain to be added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file"
  type        = string
  default     = ""
}

variable "tls_email" {
  description = "The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
variable "enable_logs_storage" {
  description = "Flag to enable or disable long term storage for logs"
  type        = bool
  default     = true
}

variable "enable_reports_storage" {
  description = "Flag to enable or disable long term storage for reports"
  type        = bool
  default     = true
}

variable "enable_repository_storage" {
  description = "Flag to enable or disable the repository bucket storage"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Flag to enable or disable External DNS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "create_and_configure_subdomain" {
  description = "Flag to create an NS record set for the subdomain in the apex domain's Hosted Zone"
  type        = bool
  default     = false
}

variable "enable_tls" {
  description = "Flag to enable TLS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "production_letsencrypt" {
  description = "Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed. If set to false, empty the bucket first in the aws s3 console, else terraform destroy will fail with BucketNotEmpty error"
  type        = bool
  default     = false
}

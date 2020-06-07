// ----------------------------------------------------------------------------
// Query necessary data for the module
// ----------------------------------------------------------------------------

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = var.terraform_state_aws_region
    bucket = var.terraform_state_s3_bucket
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

data "aws_subnet" "all" {
  count = data.terraform_remote_state.vpc.outputs.num_availability_zones
  id = element(
    data.terraform_remote_state.vpc.outputs.private_app_subnet_ids,
    count.index,
  )
}

// ----------------------------------------------------------------------------
// Define K8s cluster configuration
// ----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster[0].token
  load_config_file       = false
  version                = "1.11.1"
}

// ----------------------------------------------------------------------------
// Create the EKS cluster with extra EC2ContainerRegistryPowerUser policy
// See https://github.com/terraform-aws-modules/terraform-aws-eks
// ----------------------------------------------------------------------------
module "eks" {
  source           = "terraform-aws-modules/eks/aws"
  version          = "12.1.0"
  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  subnets          = data.aws_subnet.all.*.id
  vpc_id           = data.terraform_remote_state.vpc.outputs.vpc_id
  enable_irsa      = true
  create_eks       = var.create_eks
  worker_groups    = [
    {
      name                 = "worker-group-${var.cluster_name}"
      instance_type        = var.node_machine_type
      asg_desired_capacity = var.desired_node_count
      asg_min_size         = var.min_node_count
      asg_max_size         = var.max_node_count
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]

  cluster_endpoint_private_access       = true
  cluster_endpoint_public_access        = false
  cluster_endpoint_private_access_cidrs = ["10.0.0.0/8"]
}

// ----------------------------------------------------------------------------
// Update the kube configuration after the cluster has been created so we can
// connect to it and create the K8s resources
// ----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  depends_on = [
    module.eks
  ]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name}"
    interpreter = ["/bin/bash", "-c"]
  }
}

// ----------------------------------------------------------------------------
// Create the necessary K8s namespaces that we will need to add the
// Service Accounts later
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "jx" {
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name = "jx"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_namespace" "cert_manager" {
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name = "cert-manager"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

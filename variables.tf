variable "eks_cluster_name" {
  type        = string
  description = "The name to give to your new cluster."
}

variable "kms_key_arn" {
  type        = string
  description = "The KMS key that should be used to encrypt the secrets database within Kubernetes. This should be the 'common' KMS CMK that is present in your account."
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "The version of Kubernetes to deploy (E.g., 1.17). If not set it defaults to the latest available version but will not trigger updates when newer versions are released. Required in order to update the cluster. See the Updating section of the README."
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "CG policy requires that application team roles have a permissions boundary. Specify the ARN of the IAM policy that should be attached as a permissions boundary to all roles created by this module. If not specified, no permissions boundary will be applied."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnets in which you'd like to deploy your EKS cluster. We recommend at least three subnets in different Availability Zones to ensure that the cluster maintains quorum in the event of a failure of one AZ."
}

variable "deploy_oidc_provider" {
  type        = bool
  default     = true
  description = "Whether or not to deploy an OIDC provider for the EKS cluster"
}

variable "oidc_sc_version" {
  type        = string
  default     = "Version - 1.0"
  description = "Name of Product version that should be used to deploy the OIDC provider Service Catalog product"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags to apply to your cluster. May not be necessary if your account has auto-tagging enabled."
}
# vim: sw=2 ts=2 et

#VPC-CNI EKS Add-On
variable "vpc_cni_resolve_conflicts" {
  type        = string
  default     = "NONE"
  description = "NONE or OVERWRITE which will allow the add-on to overwrite your custom settings"
}

variable "vpc_cni_addon_version" {
  type        = string
  description = "VPC-CNI version, please ensure the version is compatible with your k8s version"
}

variable "name_prefix" {
  description = "Name prefix for EKS resources."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "subnet_ids" {
  description = "Private application subnet IDs for EKS nodes."
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Existing security group ID for EKS worker nodes."
  type        = string
}

variable "endpoint_public_access" {
  description = "Allow public access to the EKS API endpoint."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Allow private access to the EKS API endpoint from the VPC."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Managed node group root volume size in GiB."
  type        = number
  default     = 30
}

variable "irsa_policy_arns" {
  description = "IAM policy ARNs keyed by Kubernetes service account name for IRSA."
  type        = map(list(string))
  default     = {}
}

variable "namespace" {
  description = "Kubernetes namespace used in IRSA trust policies."
  type        = string
  default     = "cloudmart-prod"
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}

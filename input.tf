variable "cluster_name" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  type = list(string)
}

variable "disk_size" {
  type = number
}

variable "additional_tags" {
  default = {}
  type    = map(string)
}

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Additional tags for the RDS cluster"
  type        = map(string)
  default     = {}
}

variable "copy_tags_to_snapshot" {
  description = "Copy all cluster tags to snapshots"
  default = false
}

variable "create_cluster" {
  description = "True if the cluster should be created"
  default = true
}

variable "password" {
  description = "The master database password. If null a random one is generated."
  default = null
}

variable "store_master_password_as_parameter" {
  default = false
  type = bool
}

variable "master_password_ssm_parameter_name" {
  default = null
}

variable "master_password_ssm_parameter_tags" {
  description = "Additional tags for the SSM parameter"
  type        = map(string)
  default     = {}
}

variable "store_master_password_as_secret" {
  default = true
  type = bool
}

variable "master_password_secret_name_prefix" {
  default = null
}

variable "password_secret_tags" {
  description = "Additional tags for the secrets"
  type        = map(string)
  default     = {}
}

variable "create_security_group" {
  description = "Whether to create the security group for the RDS cluster"
  default = true
  type = bool
}

variable "security_group_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}

variable "name" {}

variable "vpc_id" {
  description = "The ID of the VPC to provision into"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to use"
  type        = list(string)
}

variable "family" {
  description = "The database family"
  default = "aurora-postgresql11"
}

variable "db_parameter_group_name" {
  description = "Optional aws_db_parameter_group name. Providing this will prevent the creation of the aws_db_parameter_group resource."
  default = null
}

variable "db_parameters" {
  description = "Map of parameters to use in the aws_db_parameter_group resource"
  type = map(string)
  default = {}
}

variable "db_parameter_group_tags" {
  description = "A map of tags to add to the aws_db_parameter_group resource if one is created."
  default = {}
}

variable "rds_cluster_parameter_group_name" {
  description = "Optional aws_rds_cluster_parameter_group name. Providing this will prevent the creation of the aws_rds_cluster_parameter_group resource."
  default = null
}

variable "rds_cluster_parameters" {
  description = "Map of the parameters to use in the aws_rds_cluster_parameter_group resource"
  type = map(string)
  default = {}
}

variable "rds_cluster_parameter_group_tags" {
  description = "A map of tags to add to the aws_rds_cluster_parameter_group resource if one is created."
  default =  {}
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "Aurora database engine version."
  type        = string
  default     = "11.9" # max version supporting proxy
}

variable "instance_type_replica" {
  description = "Instance type to use at replica instance"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Instance type to use at master instance. If instance_type_replica is not set it will use the same type for replica instances"
  type        = string
  default     = "db.r4.large"
}

variable "replica_scale_enabled" {
  description = "Whether to enable autoscaling for RDS Aurora read replicas"
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead."
  type        = number
  default     = 1
}

variable "replica_scale_max" {
  description = "Maximum number of replicas to allow scaling for"
  type        = number
  default     = 10
}

variable "replica_scale_min" {
  description = "Minimum number of replicas to allow scaling for"
  type        = number
  default     = 2
}

variable "replica_scale_cpu" {
  description = "CPU usage to trigger autoscaling at"
  type        = number
  default     = 60
}

# See https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Managing.Performance.html
variable "replica_scale_connections" {
  description = "Average number of connections to trigger autoscaling at. Default value is 70% of db.r4.large's default max_connections"
  type        = number
  default     = 700
}

variable "replica_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "replica_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Should a final snapshot be created on cluster destroy"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks which are allowed to access the database"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:00-03:00" # 7PM-8PM MST
}

variable "preferred_maintenance_window" {
  description = "When to perform DB maintenance"
  type        = string
  default     = "sat:03:00-sat:05:00" # 8PM-10PM MST
}

variable "deletion_protection" {
  description = "TEST"
  default = false
}

variable "share" {
  default = false
  type = bool
}

variable "share_tags" {
  description = "Additional tags for the resource access manager share."
  type        = map(string)
  default     = {}
}

variable "create_proxy" {
  default = false
  type = bool
}

variable "proxy_debug_logging" {
  default = false
  type = bool
}

variable "proxy_idle_client_timeout" {
  default = 1800
  type = number
}

variable "proxy_require_tls" {
  default = true
  type = bool
}

variable "proxy_iam_auth" {
  description = "One of REQUIRED or DISABLED"
  default = "REQUIRED"
}

variable "proxy_secret_arns" {
  description = "List of AWS Secret ARNs containing credentials for use by the proxy."
  type = list(string)
  default = []
}

variable "snapshot_identifier" {
  description = "DB snapshot to create this database from"
  type        = string
  default     = null
}

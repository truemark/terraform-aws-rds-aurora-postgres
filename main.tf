resource "aws_db_parameter_group" "db" {
  count = var.create_cluster && var.db_parameter_group_name == null ? 1 : 0
  name = var.name
  family = var.family
  description = "Parameter group for ${var.name}"
  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name = parameter.key
      value = parameter.value
    }
  }
  tags = merge(var.tags, var.db_parameter_group_tags)
}

resource "aws_rds_cluster_parameter_group" "db" {
  count = var.create_cluster && var.rds_cluster_parameter_group_name == null ? 1 : 0
  name = var.name
  family = var.family
  description = "Cluster parameter group for ${var.name}"
  dynamic "parameter" {
    for_each = var.rds_cluster_parameters
    content {
      name = parameter.key
      value = parameter.value
    }
  }
  tags = merge(var.tags, var.rds_cluster_parameter_group_tags)
}

module "db" {
  # https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "3.13.0"
  name = var.name
  database_name = var.database_name
  engine = "aurora-postgresql"
  engine_version = var.engine_version
  engine_mode = "provisioned"
  instance_type = var.instance_type
  instance_type_replica = var.instance_type_replica
  replica_count = var.replica_count
  replica_scale_enabled = var.replica_scale_enabled
  replica_scale_min = var.replica_scale_min
  replica_scale_max = var.replica_scale_max
  replica_scale_connections = var.replica_scale_connections
  replica_scale_cpu = var.replica_scale_cpu
  replica_scale_in_cooldown = var.replica_scale_in_cooldown
  replica_scale_out_cooldown = var.replica_scale_out_cooldown
  vpc_id = var.vpc_id
  subnets = var.subnets
  monitoring_interval = 60
  enabled_cloudwatch_logs_exports = ["postgresql"]
  apply_immediately = var.apply_immediately
  skip_final_snapshot = var.skip_final_snapshot
  storage_encrypted = true
  db_parameter_group_name = var.db_parameter_group_name == null ? element(aws_db_parameter_group.db.*.name, 1) : var.db_parameter_group_name
  db_cluster_parameter_group_name = var.rds_cluster_parameter_group_name == null ? element(aws_rds_cluster_parameter_group.db.*.name, 1) : var.rds_cluster_parameter_group_name
  allowed_cidr_blocks = var.allowed_cidr_blocks
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  deletion_protection = var.deletion_protection
  tags = var.tags
  cluster_tags = var.cluster_tags
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  security_group_tags = var.security_group_tags
  create_random_password = var.password == null
  password = var.password
  create_security_group = var.create_security_group
  snapshot_identifier = var.snapshot_identifier
}

resource "aws_ram_resource_share" "db" {
  count = var.create_cluster && var.share ? 1 : 0
  name = "${var.name}-rds"
  allow_external_principals = false
  tags = merge(var.tags, var.share_tags)
}

resource "aws_ssm_parameter" "db" {
  count = var.create_cluster && var.store_master_password_as_parameter ? 1 : 0
  name = var.master_password_ssm_parameter_name == null ? "/database/${var.name}/password/${module.db.this_rds_cluster_master_username}" : var.master_password_ssm_parameter_name
  description = "Master password for ${var.name}"
  type = "SecureString"
  value = module.db.this_rds_cluster_master_password
  tags = merge(var.tags, var.master_password_ssm_parameter_tags)
}

resource "aws_secretsmanager_secret" "db" {
  count = var.create_cluster && var.store_master_password_as_secret ? 1 : 0
  name_prefix = var.master_password_secret_name_prefix == null ? "database/${var.name}/master-" : var.master_password_secret_name_prefix
  description = "Master password for ${var.name}"
  tags = merge(var.tags, var.password_secret_tags)
}

resource "aws_secretsmanager_secret_version" "db" {
  count = var.create_cluster && var.store_master_password_as_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[count.index].id
  secret_string = jsonencode({
    "username"=module.db.this_rds_cluster_master_username
    "password"=module.db.this_rds_cluster_master_password
  })
}

module "proxy" {
  count = var.create_cluster && var.create_proxy ? 1 : 0
  source = "truemark/rds-proxy/aws"
  version = "0.0.1"
  create_proxy = var.create_proxy
  name = var.name
  secret_arns = concat([aws_secretsmanager_secret.db[count.index].arn], var.proxy_secret_arns)
  subnets = var.subnets
  vpc_id = var.vpc_id
  debug_logging = var.proxy_debug_logging
  idle_client_timeout = var.proxy_idle_client_timeout
  require_tls = var.proxy_require_tls
  engine_family = "POSTGRESQL"
  iam_auth = var.proxy_iam_auth
  db_cluster_identifier = module.db.this_rds_cluster_id
  rds_security_group_id = module.db.this_security_group_id
}

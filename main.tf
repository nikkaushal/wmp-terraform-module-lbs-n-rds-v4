module "databases" {
  for_each = var.databases
  source   = "./modules/rds"

  env               = var.env
  subnet_ids        = var.subnets
  allocated_storage = each.value["allocated_storage"]

}

# module "apps" {
#   depends_on = [module.databases]

#   source        = "./modules/component-with-alb"
#   dns_domain    = var.dns_domain
#   env           = var.env
#   subnets       = var.subnets
#   vpc_id        = var.vpc_id
#   for_each      = var.apps
#   instance_type = each.value["instance_type"]
#   component     = each.key
#   ports         = each.value["ports"]
#   lb            = each.value["lb"]
#   asg           = each.value["asg"]

# }


# -------------------------------------------------------------
# NETWORKING MODULE
# -------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  aws_region          = var.aws_region
  environment         = var.environment
}

# -------------------------------------------------------------
# COMPUTE MODULE
# -------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  vpc_id              = module.networking.vpc_id
  subnet_id           = module.networking.public_subnet_id
  instance_type       = var.instance_type
  environment         = var.environment
  ssh_public_key_path = "~/.ssh/id_showcase.pub"
}

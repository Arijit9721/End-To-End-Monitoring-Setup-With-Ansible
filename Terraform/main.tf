module "main" {
  source = "./modules"
  
  ami                    = var.ami  
  ansible_instance_type  = var.ansible_instance_type
  worker_instance_type   = var.worker_instance_type
  spoke_count           = var.spoke_count
}
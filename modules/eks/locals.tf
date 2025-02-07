locals {
  user_data = base64encode(templatefile(
    path("./linux_user_data.tpl"),
    {
      cluster_name        = var.cluster_name
      cluster_endpoint    = var.cluster_endpoint
      cluster_auth_base64 = var.cluster_auth_base64

      cluster_service_cidr = var.cluster_service_cidr
      cluster_ip_family    = var.cluster_ip_family
    }
  ))
}

# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "mushop_url_button" {
  value       = format("${local.mushop_url_protocol}://%s", local.mushop_ingress_hostname)
  description = "MuShop Storefront URL for ORM button"

  depends_on = [helm_release.ingress_nginx]
}
output "mushop_url" {
  value       = format("${local.mushop_url_protocol}://%s", local.mushop_ingress_hostname)
  description = "MuShop Storefront URL"

  depends_on = [helm_release.ingress_nginx]
}
output "mushop_url_https" {
  value       = format("https://%s", local.mushop_ingress_hostname)
  description = "MuShop Storefront Hostname"

  depends_on = [helm_release.ingress_nginx]
}
output "grafana_url" {
  value       = var.grafana_enabled ? format("${local.mushop_url_protocol}://%s/grafana", local.mushop_ingress_hostname) : null
  description = "Grafana Dashboards URL"

  depends_on = [helm_release.ingress_nginx]
}
output "domain_name" {
  value       = var.ingress_hosts != "" ? local.mushop_ingress_hostname : null
  description = "Domain name"

  depends_on = [helm_release.ingress_nginx]
}
output "external_ip" {
  value = local.mushop_ingress_ip

  depends_on = [helm_release.ingress_nginx]
}
output "autonomous_database_password" {
  value = random_string.autonomous_database_admin_password.result
}
output "grafana_admin_password" {
  value = var.grafana_enabled ? nonsensitive(local.grafana_admin_password) : null # Required for TF >= 0.15, as automatically generate an error if is not marked as sensitive
  # value     = local.grafana_admin_password # TF 0.14 version support by ORM does not support nonsensitive function
}
output "mushop_source_code" {
  value = "https://github.com/oracle-quickstart/oci-cloudnative/"
}
locals {
  mushop_ingress_ip       = var.ingress_nginx_enabled ? data.kubernetes_service.mushop_ingress.0.load_balancer_ingress.0.ip : "#Ingress_Not_Deployed"
  mushop_ingress_hostname = var.ingress_nginx_enabled ? (var.ingress_hosts == "" ? data.kubernetes_service.mushop_ingress.0.load_balancer_ingress.0.ip : split(",", var.ingress_hosts)[0]) : "#Ingress_Not_Deployed"
  mushop_url_protocol     = var.ingress_tls ? "https" : "http"
  grafana_admin_password  = var.grafana_enabled ? data.kubernetes_secret.mushop_utils_grafana.0.data.admin-password : "Grafana_Not_Deployed"
}

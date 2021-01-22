# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "node_pool_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.node_pool_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets kubeconfig
data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
  cluster_id = var.create_new_oke_cluster ? oci_containerengine_cluster.oke_mushop_cluster[0].id : var.existent_oke_cluster_id
}


locals {
  # Helm repos
  helm_repository = {
    stable        = "https://charts.helm.sh/stable"
    ingress_nginx = "https://kubernetes.github.io/ingress-nginx"
    jetstack      = "https://charts.jetstack.io"                        # cert-manager
    svc_catalog   = "https://kubernetes-sigs.github.io/service-catalog" # Service Catalog
    grafana       = "https://grafana.github.io/helm-charts"
    prometheus    = "https://prometheus-community.github.io/helm-charts"
  }
}

# MuShop
## Kubernetes Service: mushop-utils-ingress-nginx-controller
data "kubernetes_service" "mushop_ingress" {
  metadata {
    name      = "mushop-utils-ingress-nginx-controller" # mushop-utils name included to be backwards compatible to the docs and setup chart install
    namespace = kubernetes_namespace.mushop_utilities_namespace.id
  }
  depends_on = [helm_release.ingress_nginx]
}

## Kubernetes Secret: Grafana Admin Password
data "kubernetes_secret" "mushop_utils_grafana" {
  metadata {
    name      = "mushop-utils-grafana"
    namespace = kubernetes_namespace.mushop_utilities_namespace.id
  }
  depends_on = [helm_release.grafana, helm_release.mushop]
}

# OCI Services
## Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

## Object Storage
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

### Passwords using random_string instead of random_password to be compatible with ORM (Need to update random provider)
resource "random_string" "autonomous_database_wallet_password" {
  length           = 16
  special          = true
  min_upper        = 3
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "{}#^*<>[]%~"
}

resource "random_string" "autonomous_database_admin_password" {
  length           = 16
  special          = true
  min_upper        = 3
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "{}#^*<>[]%~"
}


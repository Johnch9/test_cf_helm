
resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
}

# Setup Helm provider
# Requires : kubectl -n kube-system patch deployment tiller-deploy -p '{"spec": {"template": {"spec": {"automountServiceAccountToken": true}}}}'
provider "helm" {
#  install_tiller = "true"
#   tiller_image = "ibmcom/tiller"
  install_tiller  = false
  namespace       = "kube-system"
#  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"
  service_account = "tiller"
  # tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"
  kubernetes {
    # host     = "${var.host}"
    #     # username = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
    #     # password = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"

    # client_certificate     = "${base64decode(var.client_certificate_data)}"
    # client_key             = "${base64decode(var.client_key_data)}"
    # cluster_ca_certificate = "${base64decode(var.certificate_authority_data)}"
#    config_path = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
#    config_path = "./.kube/config"
    config_path = "/app/~/.kube/config"
  }
}

# resource "null_resource" "fix_tiller_installation" {
#   depends_on = ["kubernetes_service_account.tiller"]

#   # TODO depends on tiller being installed!!! Temp fix to get around the issue with not using automountServiceAccountToken
#   provisioner "local-exec" {
#     command = <<EOF
# kubectl -n kube-system patch deployment tiller-deploy -p '{"spec": {"template": {"spec": {"automountServiceAccountToken": true}}}}'
#     EOF
#   }
# }

resource "kubernetes_cluster_role_binding" "tiller" {
    depends_on = ["kubernetes_service_account.tiller"] 
    metadata {
        name = "tiller"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        api_group = "rbac.authorization.k8s.io"
        kind = "User"
        name = "system:serviceaccount:kube-system:tiller"
    }
}

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "helm init --service-account tiller --wait"
  }
}

# resource "null_resource" "first" {
#     provisioner "local-exec" {
#         command = "echo 'first'"
#     }
# }

# resource "null_resource" "second" {
#     depends_on = ["null_resource.first"]
#     provisioner "local-exec" {
#         command = "echo 'second'"
#     }
# }

# resource "null_resource" "third" {
#     depends_on = ["null_resource.second"]
#     provisioner "local-exec" {
#         command = "echo 'third'"
#     }
# }

# Add Helm Repo for SVC Cat
# resource "helm_repository" "incubator" {
#   name = "incubator"
# #  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
#   url  = "./istio/install/kubernetes/helm/"
# }

# Deploy SvcCat
resource "helm_release" "istio" {
  depends_on = ["kubernetes_cluster_role_binding.tiller", "kubernetes_cluster_role_binding.tiller", "null_resource.helm_init"] 
  name       = "istio"
#  repository = "${helm_repository.incubator.metadata.0.name}"
  repository = ".././"
#  repository = "./istio/install/kubernetes/helm/"
  chart      = "istio"
  namespace  = "istio-system"

  set {
    name  = "istio.sidecar-injector"
    value = true
  }
}

resource "null_resource" "enable_sidecar_injection" {
  depends_on = ["helm_release.istio"]

  provisioner "local-exec" {
    command = <<EOF
kubectl label namespace default istio-injection=enabled
    EOF
  }
}


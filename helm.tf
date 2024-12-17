resource "null_resource" "helm_repository" {
  provisioner "local-exec" {
    command = "helm repo add openmetadata https://helm.open-metadata.org/"
  }
}

resource "helm_release" "openmetadata_dependencies" {

  name       = "openmetadata-dependencies"
  repository = "openmetadata"
  chart      = "openmetadata/openmetadata-dependencies"
  namespace  = local.k8s_namespace

  values = [
    file("${path.module}/yaml/openmetadata-dependencies-values.yaml")
  ]
  timeout = 1800

  depends_on = [
    null_resource.helm_repository,
    kubernetes_namespace.k8s,
    kubernetes_secret.mysql_secrets,
    kubernetes_secret.airflow_secrets,
    kubernetes_secret.airflow_mysql_secrets
  ]
}

resource "helm_release" "openmetadata" {
  depends_on = [helm_release.openmetadata_dependencies]

  name       = "openmetadata"
  repository = "openmetadata"
  chart      = "openmetadata/openmetadata"
  namespace  = local.k8s_namespace

  values = [
    file("${path.module}/yaml/openmetadata-values.yaml")
  ]
  timeout = 1800
}

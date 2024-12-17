locals {
  k8s_namespace = "${var.k8s_namespace}"
}

resource "kubernetes_namespace" "k8s" {
  metadata {
    name = local.k8s_namespace
  }
}

resource "kubernetes_persistent_volume_claim" "dependencies_dags_pvc" {
  metadata {
    name      = "openmetadata-dependencies-dags-pvc"
    namespace = kubernetes_namespace.k8s.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }

    storage_class_name = "azurefile"
  }
}

resource "kubernetes_persistent_volume_claim" "dependencies_logs_pvc" {
  metadata {
    name      = "openmetadata-dependencies-logs-pvc"
    namespace = kubernetes_namespace.k8s.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = "azurefile"
  }
}

resource "kubernetes_job" "permission_pod" {
  metadata {
    name      = "permission-pod"
    namespace = kubernetes_namespace.k8s.metadata[0].name
    labels = {
      run = "permission-pod"
    }
  }

  spec {
    template {
      metadata {
        labels = {
          run = "permission-pod"
        }
      }
      spec {
        container {
          image = "busybox"
          name  = "permission-pod"

          command = [
            "/bin/sh",
            "-c",
            "chown -R 50000 /airflow-dags /airflow-logs",
            "chmod -R a+rwx /airflow-dags",
          ]

          volume_mount {
            mount_path = "/airflow-dags"
            name       = "airflow-dags"
          }

          volume_mount {
            mount_path = "/airflow-logs"
            name       = "airflow-logs"
          }
        }

        restart_policy = "Never"

        volume {
          name = "airflow-logs"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.dependencies_logs_pvc.metadata[0].name
          }
        }

        volume {
          name = "airflow-dags"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.dependencies_dags_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "mysql_secrets" {
  metadata {
    name      = "mysql-secrets"
    namespace = kubernetes_namespace.k8s.metadata[0].name
  }

  data = {
    openmetadata-mysql-password = var.om_mysql_password
  }

  type = "Opaque"
}

resource "kubernetes_secret" "airflow_secrets" {
  metadata {
    name      = "airflow-secrets"
    namespace = kubernetes_namespace.k8s.metadata[0].name
  }

  data = {
    openmetadata-airflow-password = var.om_airflow_password
  }

  type = "Opaque"
}

resource "kubernetes_secret" "airflow_mysql_secrets" {
  metadata {
    name      = "airflow-mysql-secrets"
    namespace = kubernetes_namespace.k8s.metadata[0].name
  }

  data = {
    airflow-mysql-password = var.airflow_mysql_password
  }

  type = "Opaque"
}

resource "kubernetes_service" "openmetadata_lb" {
  metadata {
    name      = "openmetadata-lb"
    namespace = kubernetes_namespace.k8s.metadata[0].name
  }

  spec {
    selector = {
      "app.kubernetes.io/instance" = "openmetadata"
      "app.kubernetes.io/name"     = "openmetadata"
    }

    port {
      port        = 8585
      target_port = 8585
    }

    type = "LoadBalancer"
  }
}

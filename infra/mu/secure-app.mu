# -----------------------------------------
# µs Reactive IaC for secure-app
# -----------------------------------------

var app_name     = "secure-app"
var namespace    = "secure-app"
var image_name   = "secure-app"
var image_tag    = "local"

# -----------------------------------------
# Desired State
# -----------------------------------------

resource "kubernetes_namespace" "ns" {
  name = namespace
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = app_name
    namespace = namespace
  }

  spec {
    replicas = 2

    container {
      name  = app_name
      image = "${image_name}:${image_tag}"
      port  = 8080

      env {
        name  = "PORT"
        value = "8080"
      }
    }
  }
}

# -----------------------------------------
# Reactive Rule: Image Change
# -----------------------------------------

react "on_image_change" {
  watch = file("./.image.digest")

  action {
    log("Image changed → triggering redeploy")
    apply(kubernetes_deployment.app)
  }
}

# -----------------------------------------
# Reactive Policy Gate
# -----------------------------------------

react "policy_enforcement" {
  before = apply(kubernetes_deployment.app)

  condition {
    file_exists("./policy/allow-deploy")
  }

  otherwise {
    error("Deployment blocked by policy")
  }
}

variable "gcp_project" {
  type = string
}

variable "region" {
  type = string
}

variable "policy_members" {
  type = list(string)
}

variable "run_service_account" {
  type = string
}

provider "google" {
  project = var.gcp_project
}

resource "google_project_service" "workflows" {
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "workflows_service_account" {
  account_id   = "sample-workflows-sa"
  display_name = "Sample Workflows Service Account"
}

resource "google_cloud_run_service" "run-axum-test" {
  name                       = "axum-test"
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = format("gcr.io/%s/axum-test:latest", var.gcp_project)
        env {
          name  = "RUST_LOG"
          value = "DEBUG"
        }
      }
    }
  }
}

data "google_iam_policy" "run_policy" {
  binding {
    role    = "roles/run.invoker"
    members = var.policy_members
  }
}

locals {
  workflow = templatefile("workflow.yaml", {
    "cloud_run_url" : google_cloud_run_service.run-axum-test.status[0].url
  })
  depends_on = [
    google_cloud_run_service.run-axum-test,
  ]
}

resource "google_cloud_run_service_iam_policy" "myself" {
  location    = google_cloud_run_service.run-axum-test.location
  project     = google_cloud_run_service.run-axum-test.project
  service     = google_cloud_run_service.run-axum-test.name
  policy_data = data.google_iam_policy.run_policy.policy_data
}

resource "google_workflows_workflow" "workflows_example" {
  name            = "sample-workflow"
  region          = var.region
  description     = "A sample workflow"
  service_account = var.run_service_account
  source_contents = local.workflow

  depends_on = [
    google_project_service.workflows,
    google_cloud_run_service.run-axum-test,
  ]
}

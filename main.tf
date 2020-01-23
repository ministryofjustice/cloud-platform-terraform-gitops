data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

# All variables in provider.concourse are defined in the
# cloud-platform-environments:build pipeline.
provider "concourse" {
  url  = var.concourse_url
  team = "main" # has to be main to approve change

  username = var.concourse_basic_auth_username
  password = var.concourse_basic_auth_password
}

# Team and pipeline creation
data "template_file" "pipeline" {
  template = file("${path.module}/pipeline.yaml")

  vars = {
    namespace       = var.namespace
    source_code_url = var.source_code_url
    branch          = var.branch
    github_team     = var.github_team
  }
}

resource "concourse_team" "my_team" {
  team_name = var.github_team

  owners = [
    "user:local:((concourse-basic-auth.username))",
    "group:github:ministryofjustice:${var.github_team}",
    "group:github:ministryofjustice:webops",
  ]

  viewers = [
    "group:github:ministryofjustice",
  ]
}

resource "concourse_pipeline" "namespace_pipeline" {
  depends_on    = [data.template_file.pipeline]
  team_name     = var.github_team
  pipeline_name = var.namespace

  is_exposed = false
  is_paused  = false

  pipeline_config        = data.template_file.pipeline.rendered
  pipeline_config_format = "yaml"
}


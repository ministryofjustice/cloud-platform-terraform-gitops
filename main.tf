data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# All variables in provider.concourse are defined in the
# cloud-platform-environments:build pipeline.
provider "concourse" {
  url  = "${var.concourse_url}"
  team = "main" # has to be main to approve change

  username = "${var.concourse_basic_auth_username}"
  password = "${var.concourse_basic_auth_password}"
}

#output "my_team_owners" {
#  value = "${data.concourse_team.my_team.owners}"
#}
#
#output "my_team_members" {
#  value = "${data.concourse_team.my_team.members}"
#}

resource "concourse_team" "my_team" {
  team_name = "${var.github_team}"

  owners = [
    "group:github:ministryofjustice:${var.github_team}",
    "group:github:ministryofjustice:webops"
  ]

  viewers = [
    "group:github:ministryofjustice",
  ]
}

resource "concourse_pipeline" "namespace_pipeline" {
  team_name     = "${var.github_team}"
  pipeline_name = "${var.namespace}"

  is_exposed = false
  is_paused  = true

  pipeline_config        = "${file("${path.module}/z.yml")}"
  pipeline_config_format = "yaml"
}

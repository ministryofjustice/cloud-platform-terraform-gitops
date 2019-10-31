data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "concourse" {
  url  = "https://z.apps.concourse-op.cloud-platform.service.justice.gov.uk/"
  team = "main"

  username = "${var.CONCOURSE_BASIC_AUTH_USERNAME}"
  password = "${var.CONCOURSE_BASIC_AUTH_PASSWORD}"
}

data "concourse_team" "my_team" {
  team_name = "main"
}

output "my_team_owners" {
  value = "${data.concourse_team.my_team.owners}"
}

output "my_team_members" {
  value = "${data.concourse_team.my_team.members}"
}

resource "concourse_team" "my_team" {
  team_name = "z"

  owners = [
    "user:github:razvan-moj",
  ]

  viewers = [
    "user:github:jasonBirchall"
  ]
}

resource "concourse_pipeline" "my_pipeline" {
  team_name     = "z"
  pipeline_name = "z"

  is_exposed = false
  is_paused  = true

  pipeline_config        = "${file("z.yml")}"
  pipeline_config_format = "yaml"
}

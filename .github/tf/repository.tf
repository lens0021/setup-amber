import {
  id = "setup-amber"
  to = github_repository.this
}
resource "github_repository" "this" {
  allow_auto_merge            = true
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_squash_merge          = true
  allow_update_branch         = true
  archived                    = false
  archive_on_destroy          = true
  auto_init                   = false
  delete_branch_on_merge      = true
  description                 = "Download amber compiler"
  has_discussions             = false
  has_issues                  = true
  has_projects                = false
  has_wiki                    = false
  homepage_url                = ""
  name                        = "setup-amber"
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"
  topics                      = ["amber"]
  visibility                  = "public"
  vulnerability_alerts        = true
  web_commit_signoff_required = false

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}

# secrets.GITHUB_TOKEN does not have the permission for this:
# import {
#   id = "setup-amber"
#   to = github_workflow_repository_permissions.this
# }
# resource "github_workflow_repository_permissions" "this" {
#   repository                       = github_repository.this.name
#   default_workflow_permissions     = "read"
#   can_approve_pull_request_reviews = true
# }

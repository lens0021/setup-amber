import {
  id = "setup-amber:10629749"
  to = github_repository_ruleset.default
}
resource "github_repository_ruleset" "default" {
  name        = "default"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH", ]
      exclude = []
    }
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = false
    update                  = true

    pull_request {
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_approving_review_count   = 0
      required_review_thread_resolution = false
    }

    required_status_checks {
      do_not_enforce_on_create             = false
      strict_required_status_checks_policy = false

      dynamic "required_check" {
        for_each = [
          "biome",
          "check-dist",
          "--> Linted: CHECKOV",
          "--> Linted: GITHUB_ACTIONS",
          "--> Linted: GITLEAKS",
          "--> Linted: GIT_MERGE_CONFLICT_MARKERS",
          "--> Linted: JSCPD",
          "rumdl",
          "Test with default settings (macos-latest)",
          "Test with default settings (ubuntu-latest)",
          "zizmor",
        ]
        content {
          context        = required_check.value
          integration_id = 15368
        }
      }
    }

  }
}

# Heimdall

Automated Pull Request Tracking

`pr.csv` contains PRs awaiting reviews (`review-requested`) or authors (`authored`) for each team member.

This [gsheet](https://docs.google.com/spreadsheets/d/1PoB0zUG5kA4RmYVJQttt7a6ojRkMZ9VH_hAzs4Byogs/edit?gid=0#gid=0) imports this CSV for easy browsing.

## Setup

1. Fork the repo and update `pr_tracker.sh` with your team members.
2. Create a classic Personal Access Token (PAT) in GitHub Settings > Developer settings > Personal access tokens. Select the "repo" scope for full control of private repositories and the "read:org" scope to read org and team membership.
3. Add the PAT to your forked repository's secrets (Settings > Secrets and variables > Actions) as `PERSONAL_ACCESS_TOKEN`.

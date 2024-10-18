# Heimdall

Automated Pull Request Tracking

## Reports

- `pr_reviews.csv`: PRs awaiting reviews.
- `authored_prs.csv`: PRs authored by team members.

## Setup

1. **Create a Personal Access Token (PAT)**
   - **Scopes:**
     - **Metadata:** Read-only
     - **Pull requests:** Read-only
2. **Add PAT to Repository Secrets**
   - Go to **Settings > Secrets and variables > Actions**
   - Add a new secret named `PERSONAL_ACCESS_TOKEN` with your PAT.

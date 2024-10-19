# Heimdall

Automated Pull Request Tracking

`pr.csv` contains PRs awaiting reviews (`review-requested`) or authors (`authored`) for each team member.

This [gsheet](https://docs.google.com/spreadsheets/d/1PoB0zUG5kA4RmYVJQttt7a6ojRkMZ9VH_hAzs4Byogs/edit?gid=0#gid=0) imports this CSV for easy browsing.

## Setup

1. **Create a Personal Access Token (PAT)**
   - **Scopes:**
     - **Metadata:** Read-only
     - **Pull requests:** Read-only
2. **Add PAT to Repository Secrets**
   - Go to **Settings > Secrets and variables > Actions**
   - Add a new secret named `PERSONAL_ACCESS_TOKEN` with your PAT.

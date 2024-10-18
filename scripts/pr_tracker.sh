#!/bin/bash

# combined_pr_tracker.sh

# =======================
# Configuration
# =======================

# Define team members
TEAM_MEMBERS=("afermg" "shntnu")  # Replace with your team members

# Output CSV files
REVIEWS_CSV="pr_reviews.csv"
AUTHORED_CSV="authored_prs.csv"

# Temporary files to store PR data
REVIEWS_TEMP=$(mktemp)
AUTHORED_TEMP=$(mktemp)

# Function to clean up temporary files on exit
cleanup() {
  rm -f "$REVIEWS_TEMP" "$AUTHORED_TEMP"
}
trap cleanup EXIT

# =======================
# Function Definitions
# =======================

# Function to fetch PRs awaiting reviews
fetch_reviews() {
  echo "Fetching PRs awaiting reviews..."

  for reviewer in "${TEAM_MEMBERS[@]}"; do
    echo "Processing reviewer: $reviewer"

    # Fetch open PRs requesting review from the current reviewer
    gh search prs --review-requested="$reviewer" --state=open --json title,url,repository,author,createdAt \
      --jq '.[] | {
        title: .title,
        url: .url,
        repository: .repository.nameWithOwner,
        author: .author.login,
        createdAt: .createdAt,
        reviewer: "'"$reviewer"'"
      }' >> "$REVIEWS_TEMP"
  done

  # Check if any PRs were found
  if [[ ! -s "$REVIEWS_TEMP" ]]; then
    echo "No open PRs awaiting reviews."
    touch "$REVIEWS_TEMP"  # Ensure the file exists for later processing
  fi
}

# Function to fetch PRs authored by team members
fetch_authored_prs() {
  echo "Fetching PRs authored by team members..."

  for author in "${TEAM_MEMBERS[@]}"; do
    echo "Processing author: $author"

    # Fetch open PRs authored by the current author
    gh search prs --author="$author" --state=open --json title,url,repository,author,createdAt,commentsCount \
      --jq '.[] | {
        title: .title,
        url: .url,
        repository: .repository.nameWithOwner,
        author: .author.login,
        createdAt: .createdAt,
        commentsCount: .commentsCount
      }' >> "$AUTHORED_TEMP"
  done

  # Check if any PRs were found
  if [[ ! -s "$AUTHORED_TEMP" ]]; then
    echo "No open PRs authored by team members."
    touch "$AUTHORED_TEMP"  # Ensure the file exists for later processing
  fi
}

# Function to aggregate PR reviews data
aggregate_reviews() {
  echo "Aggregating PR reviews data..."

  jq -s '
    group_by(.url) |
    map({
      title: .[0].title,
      url: .[0].url,
      repository: .[0].repository,
      author: .[0].author,
      createdAt: .[0].createdAt,
      reviewers: map(.reviewer) | unique
    })
  ' "$REVIEWS_TEMP" > aggregated_reviews.json
}

# Function to aggregate authored PRs data
aggregate_authored() {
  echo "Aggregating authored PRs data..."

  jq -s '
    group_by(.url) |
    map({
      title: .[0].title,
      url: .[0].url,
      repository: .[0].repository,
      author: .[0].author,
      createdAt: .[0].createdAt,
      commentsCount: .[0].commentsCount
    })
  ' "$AUTHORED_TEMP" > aggregated_authored_prs.json
}

# Function to generate CSV with headers
generate_csv() {
  # Generate PR Reviews CSV
  if [[ -s "aggregated_reviews.json" ]]; then
    echo "Generating $REVIEWS_CSV..."

    jq -r '
      ["Repository", "PR Title", "Author", "Created At", "Reviewers", "URL"],
      (.[] | [.repository, .title, .author, (.createdAt | split("T")[0]), (.reviewers | join(", ")), .url])
      | @csv
    ' aggregated_reviews.json > "$REVIEWS_CSV"

    echo "CSV report generated at $REVIEWS_CSV"
  else
    echo "No PR reviews data to generate $REVIEWS_CSV."
    echo "Repository,PR Title,Author,Created At,Reviewers,URL" > "$REVIEWS_CSV"
  fi

  # Generate Authored PRs CSV
  if [[ -s "aggregated_authored_prs.json" ]]; then
    echo "Generating $AUTHORED_CSV..."

    jq -r '
      ["Repository", "PR Title", "Author", "Created At", "Comments Count", "URL"],
      (.[] | [.repository, .title, .author, (.createdAt | split("T")[0]), .commentsCount, .url])
      | @csv
    ' aggregated_authored_prs.json > "$AUTHORED_CSV"

    echo "CSV report generated at $AUTHORED_CSV"
  else
    echo "No authored PRs data to generate $AUTHORED_CSV."
    echo "Repository,PR Title,Author,Created At,Comments Count,URL" > "$AUTHORED_CSV"
  fi
}

# Function to display summary
display_summary() {
  echo -e "\n=== Pull Requests Awaiting Reviews ==="
  if [[ -s "$REVIEWS_CSV" ]]; then
    column -t -s ',' "$REVIEWS_CSV" | less -S
  else
    echo "No PRs awaiting reviews."
  fi

  echo -e "\n=== Pull Requests Authored by Team Members ==="
  if [[ -s "$AUTHORED_CSV" ]]; then
    column -t -s ',' "$AUTHORED_CSV" | less -S
  else
    echo "No authored PRs found."
  fi
}

# =======================
# Main Execution Flow
# =======================

echo "Starting Combined PR Tracker..."

# Fetch data
fetch_reviews
fetch_authored_prs

# Aggregate data
aggregate_reviews
aggregate_authored

# Generate CSV reports
generate_csv

# Display summary (optional)
# Uncomment the following line if you want to display the CSV content in the terminal
# display_summary

echo "Combined PR tracking completed successfully."

# =======================
# End of Script
# =======================
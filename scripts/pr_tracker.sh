#!/bin/bash

TEAM_MEMBERS=("alxndrkalinin" "johnarevalo" "afermg" "leoank" "srijitseal" "jessica-ewald" "sarakh1999" "HugoHakem" "timtreis" "shntnu" "AnneCarpenter")  # Replace with your team members
#TEAM_MEMBERS=("afermg" "leoank")

{
  for member in "${TEAM_MEMBERS[@]}"; do
      for action in "review-requested" "authored"; do
          if [ "${action}" = "review-requested" ]; then
              search_option="--review-requested=${member}"
              type_value="review-requested"
              reviewer_value="${member}"
          else
              search_option="--author=${member}"
              type_value="authored"
              reviewer_value=""
          fi

          gh search prs "${search_option}" --state=open --json title,url,repository,author,createdAt \
          | jq -r --arg type "${type_value}" --arg reviewer "${reviewer_value}" '.[] | {
              type: $type,
              title: .title,
              url: .url,
              repository: .repository.nameWithOwner,
              author: .author.login,
              createdAt: .createdAt,
              reviewer: $reviewer
          }'
          sleep 1 # because of API rate limit
      done
  done
} |
jq -s '.' | \
jq -r '
  ["Type", "Repository", "PR Title", "Author", "Created At", "Reviewer", "URL"],
  (.[] | [.type, .repository, .title, .author, (.createdAt | split("T")[0]), .reviewer, .url])
  | @csv
' > pr.csv

echo "PR tracking completed successfully."

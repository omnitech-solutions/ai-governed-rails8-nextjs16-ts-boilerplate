#!/bin/bash

# Create the workflows directory if it doesn't exist
mkdir -p .windsurf/workflows

# Loop through all command files in .ai-rulez/commands/
for file in .ai-rulez/commands/*.md; do
  # Extract filename without extension
  filename=$(basename "$file" .md)

  # Skip if it's the existing review.md (optional)
  if [ "$filename" = "review" ]; then
    echo "Skipping review.md (already exists)"
    continue
  fi

  # Create the workflow file with proper Windsurf frontmatter
  cat > ".windsurf/workflows/${filename}.md" << EOF
---
name: ${filename}
description: $(grep -m 1 "^description:" "$file" | sed 's/^description: //' | sed 's/^"//;s/"$//')
---
$(tail -n +2 "$file" | sed '/^---$/,/^---$/d')
EOF

  echo "Created .windsurf/workflows/${filename}.md"
done

echo "Done! All workflows created."
#!/bin/bash

echo "🔧 Setting up OpenCode configuration..."

# ----------------------------------------------------------------------
# 1. COMMANDS: Convert .ai-rulez/commands/ to .opencode/commands/
# ----------------------------------------------------------------------
mkdir -p .opencode/commands

for file in .ai-rulez/commands/*.md; do
  if [ ! -f "$file" ]; then
    echo "⚠️  No command files found in .ai-rulez/commands/"
    break
  fi

  filename=$(basename "$file" .md)
  description=$(grep -m 1 "^description:" "$file" | sed 's/^description: //' | sed 's/^"//;s/"$//')

  # Create OpenCode command file with proper frontmatter
  cat > ".opencode/commands/${filename}.md" << EOF
---
description: "${description}"
---

EOF

  # Extract content after the second --- (YAML frontmatter end)
  awk '/^---$/ {count++; next} count==2 {print}' "$file" >> ".opencode/commands/${filename}.md"

  # Replace {{ARGUMENTS}} with $ARGUMENTS (OpenCode syntax)
  sed -i '' 's/{{ARGUMENTS}}/$ARGUMENTS/g' ".opencode/commands/${filename}.md"

  echo "  ✅ Created command: ${filename}"
done

# ----------------------------------------------------------------------
# 2. RULES: Convert .ai-rulez/rules/ and domain rules to .opencode/rules/
# ----------------------------------------------------------------------
mkdir -p .opencode/rules

# Process root rules
for file in .ai-rulez/rules/*.md; do
  if [ ! -f "$file" ]; then
    echo "⚠️  No rule files found in .ai-rulez/rules/"
    break
  fi

  filename=$(basename "$file")
  priority=$(grep -m 1 "^priority:" "$file" | sed 's/^priority: //')

  # Create OpenCode rule file with conditional frontmatter
  cat > ".opencode/rules/${filename}" << EOF
---
priority: ${priority:-medium}
alwaysApply: ${priority:-medium} == "critical" || ${priority:-medium} == "high"
---

EOF

  # Extract content after YAML frontmatter
  awk '/^---$/ {count++; next} count==2 {print}' "$file" >> ".opencode/rules/${filename}"

  echo "  ✅ Created rule: ${filename}"
done

# Process domain-specific rules
for domain_dir in .ai-rulez/domains/*/rules; do
  if [ ! -d "$domain_dir" ]; then
    continue
  fi

  domain=$(basename "$(dirname "$domain_dir")")

  for file in "$domain_dir"/*.md; do
    if [ ! -f "$file" ]; then
      continue
    fi

    filename=$(basename "$file")
    priority=$(grep -m 1 "^priority:" "$file" | sed 's/^priority: //')

    cat > ".opencode/rules/${domain}--${filename}" << EOF
---
priority: ${priority:-medium}
alwaysApply: false
globs: ["**/*.rb"]
domain: ${domain}
---

EOF

    awk '/^---$/ {count++; next} count==2 {print}' "$file" >> ".opencode/rules/${domain}--${filename}"

    echo "  ✅ Created rule: ${domain}--${filename}"
  done
done

# ----------------------------------------------------------------------
# 3. AGENTS: Convert .ai-rulez/agents.yaml to .opencode/agents/
# ----------------------------------------------------------------------
mkdir -p .opencode/agents

if [ -f ".ai-rulez/agents.yaml" ]; then
  # Use Ruby to parse YAML and generate agent files
  ruby -r yaml -e '
    config = YAML.load_file(".ai-rulez/agents.yaml")
    config["agents"].each do |agent|
      name = agent["name"]
      description = agent["description"]
      system_prompt = agent["system_prompt"]

      File.open(".opencode/agents/#{name}.md", "w") do |f|
        f.puts "---"
        f.puts "name: #{name}"
        f.puts "description: #{description}"
        f.puts "---"
        f.puts
        f.puts system_prompt
      end
      puts "  ✅ Created agent: #{name}"
    end
  ' 2>/dev/null || echo "  ⚠️  Ruby not available for agent generation"
fi

# ----------------------------------------------------------------------
# 4. CONTEXT: Create root AGENTS.md with architecture context
# ----------------------------------------------------------------------
if [ -f ".ai-rulez/context/architecture.md" ]; then
  cat > "AGENTS.md" << EOF
---
alwaysApply: true
---

EOF

  awk '/^---$/ {count++; next} count==2 {print}' ".ai-rulez/context/architecture.md" >> "AGENTS.md"

  echo "" >> "AGENTS.md"
  echo "## Project Rules" >> "AGENTS.md"
  echo "" >> "AGENTS.md"
  echo "See \`.opencode/rules/\` for detailed coding standards." >> "AGENTS.md"

  echo "  ✅ Created AGENTS.md with architecture context"
fi

echo ""
echo "✅ OpenCode configuration complete!"
echo ""
echo "📁 Generated files:"
echo "   - .opencode/commands/   ($(ls -1 .opencode/commands/ 2>/dev/null | wc -l | tr -d ' ') commands)"
echo "   - .opencode/rules/      ($(ls -1 .opencode/rules/ 2>/dev/null | wc -l | tr -d ' ') rules)"
echo "   - .opencode/agents/     ($(ls -1 .opencode/agents/ 2>/dev/null | wc -l | tr -d ' ') agents)"
echo "   - AGENTS.md             (root context)"
echo ""
echo "Usage in OpenCode:"
echo "   /project:feature        - Run a command"
echo "   @model-agent            - Invoke an agent"
#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Cleaning up old AI tool configuration files..."

# Remove generated directories
rm -rf .cursor .windsurf .claude .opencode .gemini .continue

# Remove generated root files and GitHub Copilot instructions
rm -f AGENTS.md CLAUDE.md GEMINI.md .github/copilot-instructions.md

echo "✅ Cleanup complete."

echo "🔍 Validating .ai-rulez/ configuration..."
ai-rulez validate

echo "🔄 Generating fresh AI tool files from .ai-rulez/ source..."
ai-rulez generate

echo "📦 Syncing project-specific workflows and rules..."
pnpm workflows:sync
pnpm opencode:sync
pnpm strip-timestamps

echo "✨ All done! AI tool configurations have been regenerated."

# ------------------------------------------------------------------------------
# What just happened (high‑level):
# ------------------------------------------------------------------------------
# 1. Removed any previously generated AI tool directories (.cursor, .windsurf,
#    .claude, .opencode, .gemini, .continue) and root config files (AGENTS.md,
#    CLAUDE.md, GEMINI.md, .github/copilot-instructions.md).
# 2. Checked that your .ai-rulez/ configuration is valid.
# 3. Recreated all AI tool files from the current .ai-rulez/ source.
# 4. Ran your custom sync scripts to keep workflows, OpenCode rules, and
#    timestamps in sync with the freshly generated files.
# ------------------------------------------------------------------------------
---
name: test
aliases: [specs, run-tests]
description: Run RSpec tests (including RSwag) and help debug failures.
targets: [claude, cursor, windsurf, gemini]
---
# /test – Run and Debug Tests

Run the test suite for **{{ARGUMENTS}}** (e.g., a specific file, or `spec` for all).

1. Execute `rspec {{ARGUMENTS}} --format documentation` 
2. If all pass, celebrate 🎉
3. If there are failures:
   - Show the failing test output
   - Analyze the failure reason (pay attention to JSON:API structure, pagination meta, or RSwag schema mismatches)
   - **If error is truncated**, re‑run with `--backtrace` or inspect `log/test.log` (e.g., `tail -50 log/test.log`)
   - Suggest a fix (but let me decide whether to apply it)

If no argument is given, run the whole suite: `rspec spec` 

**Common debugging commands:**
```bash
# Full backtrace on failure
bundle exec rspec --backtrace

# View recent test log
tail -50 log/test.log
```

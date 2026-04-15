---
name: security
aliases: [audit, security-check]
description: Perform a security audit on the current codebase or specific file.
targets: [claude, cursor, windsurf]
---
# /security – Security Audit

Audit **{{ARGUMENTS}}** (or the currently open file) for security vulnerabilities.

Focus on:
- **Mass Assignment**: Does `BaseController#resource_params` use `writable_attributes` correctly? Any `params.permit!`?
- **SQL Injection**: Any string interpolation in ActiveRecord queries? (Check custom Graphiti filters.)
- **Insecure Direct Object References**: Does the user have authorization to access the requested resource? (Note: This app currently lacks authentication – note if it's needed.)
- **Sensitive Data Exposure**: Any secrets hardcoded? Are logs filtering parameters?

If you find issues, provide a clear explanation and a code fix.

If Brakeman MCP server is configured, you can also run: `brakeman -f json`

---
priority: high
domain: security
---

# Rails Security Guidelines

Protect the application from common vulnerabilities.

- **Mass Assignment**: `BaseController#resource_params` uses `writable_attributes` from Graphiti resources. Never use `params.permit!` indiscriminately.
- **SQL Injection**: Use ActiveRecord's query interface; avoid string interpolation in `where`. Custom Graphiti filters use parameterized queries.
- **Secrets Management**: Use Rails credentials or environment variables; never hardcode secrets.
- **CORS**: Configure `rack-cors` if the API is called from a different origin (not currently set up).
- **Rate Limiting**: Consider adding `rack-attack` for production.
- **Brakeman**: Run `brakeman` in CI (already configured in `.github/workflows/ci.yml`).

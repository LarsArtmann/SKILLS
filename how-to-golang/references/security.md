# Security

Distilled from rules 027-032 and 040. Security is not a feature — it's a requirement.

## Rule 027: Authentication & Authorization

Never roll your own auth. Use proven libraries.

| Concern       | Library             | Import                         |
| ------------- | ------------------- | ------------------------------ |
| JWT tokens    | golang-jwt/v5       | `github.com/golang-jwt/jwt/v5` |
| RBAC/ABAC     | casbin              | `github.com/casbin/casbin`     |
| OAuth2        | golang.org/x/oauth2 | `golang.org/x/oauth2`          |
| Password hash | argon2 or bcrypt    | `golang.org/x/crypto/argon2`   |

### Auth Middleware (Gin)

```go
func AuthMiddleware(jwtKey func(token string) (Claims, error)) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := strings.TrimPrefix(c.GetHeader("Authorization"), "Bearer ")
        if token == "" {
            c.AbortWithStatusJSON(401, gin.H{"error": "missing token"})
            return
        }
        claims, err := jwtKey(token)
        if err != nil {
            c.AbortWithStatusJSON(401, gin.H{"error": "invalid token"})
            return
        }
        c.Set("claims", claims)
        c.Next()
    }
}
```

## Rule 028: API Security

Every API endpoint enforces: rate limiting, input validation, security headers.

### Rate Limiting

```go
import "golang.org/x/time/rate"

func RateLimitMiddleware(r *rate.Limiter) gin.HandlerFunc {
    return func(c *gin.Context) {
        if !r.Allow() {
            c.AbortWithStatusJSON(429, gin.H{"error": "rate limit exceeded"})
            return
        }
        c.Next()
    }
}
```

### Security Headers

```go
func SecurityHeaders() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Header("X-Content-Type-Options", "nosniff")
        c.Header("X-Frame-Options", "DENY")
        c.Header("X-XSS-Protection", "0") // Deprecated; use CSP instead
        c.Header("Content-Security-Policy", "default-src 'self'")
        c.Header("Strict-Transport-Security", "max-age=63072000; includeSubDomains")
        c.Next()
    }
}
```

### Input Validation

Use Huma struct tags for API validation, or `govalid` for domain validation. Never trust client input.

## Rule 030: Security Testing

Automate security scanning in CI/CD on every change.

| Scan Type   | Tool          | When          |
| ----------- | ------------- | ------------- |
| SAST        | `gosec`       | Every push    |
| Dependency  | `govulncheck` | Every push    |
| Secret leak | `gitleaks`    | Pre-commit    |
| Container   | `trivy`       | Before deploy |

```yaml
# CI
- name: Security scan
  run: |
    go install github.com/securego/gosec/v2/cmd/gosec@latest
    gosec ./...
- name: Vulnerability check
  run: |
    go install golang.org/x/vuln/cmd/govulncheck@latest
    govulncheck ./...
```

## Rule 031: Data Encryption

- **In transit**: TLS 1.2+ on all connections; HSTS header
- **At rest**: AES-256-GCM for sensitive fields; column-level encryption in DB
- **In memory**: minimize plaintext exposure; zero buffers after use
- **Hashing passwords**: argon2id (preferred) or bcrypt; never SHA-256

```go
// Password hashing with argon2id
import "golang.org/x/crypto/argon2"

func HashPassword(password string, salt []byte) []byte {
    return argon2.IDKey([]byte(password), salt, 3, 64*1024, 4, 32)
}
```

## Rule 032: OWASP Top 10 Compliance

| OWASP Risk             | Prevention in Go                                     |
| ---------------------- | ---------------------------------------------------- |
| A01 Broken Access      | casbin RBAC on every endpoint                        |
| A02 Crypto Failures    | TLS 1.2+, argon2id, no MD5/SHA1                      |
| A03 Injection          | sqlc parameterized queries — never string concat     |
| A04 Insecure Design    | Threat model every new feature                       |
| A05 Security Misconfig | Security headers, no debug in prod                   |
| A06 Vulnerable Deps    | `govulncheck` + Dependabot in CI                     |
| A07 Auth Failures      | Rate limit login, no plaintext passwords             |
| A08 Data Integrity     | Verify JWT signatures, validate all input            |
| A09 Logging            | Never log secrets, structured audit trails           |
| A10 SSRF               | Validate all outbound URLs, allowlist external hosts |

## Rule 040: Container Security

- Use minimal base images (`scratch` or `distroless` for Go)
- Run as non-root user
- Read-only filesystem
- Scan images with `trivy` before deploy

```dockerfile
FROM gcr.io/distroless/static-debian12:nonroot
COPY --chmod=444 bin/server /server
USER 65532:65532
ENTRYPOINT ["/server"]
```

# Swift Security

> **Scope**: Swift-specific security (iOS, macOS, Vapor)
> **Extends**: general/security.md
> **Applies to**: *.swift files

## 1. iOS/macOS Security

### Keychain
- **ALWAYS**: Keychain Services API for sensitive data (tokens, passwords, keys).
- **ALWAYS**: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` for access control.
- **ALWAYS**: Parameterized keychain queries (avoid hardcoded values).
- **NEVER**: `UserDefaults` or plist files for secrets (plaintext).

### App Transport Security (ATS)
- **ALWAYS**: HTTPS only (`NSAppTransportSecurity` → `NSAllowsArbitraryLoads: false`).
- **ALWAYS**: Certificate pinning for critical APIs (URLSession with custom delegate).
- **NEVER**: Disable ATS in production.

### Data Protection
- **ALWAYS**: File Protection API (`FileManager` with `.complete` protection class).
- **ALWAYS**: Encrypt sensitive data at rest (CryptoKit).

## 2. Vapor (Server-Side)

### Authentication
- **ALWAYS**: Vapor's JWT authentication with expiration.
- **ALWAYS**: `BCryptDigest` for password hashing (12+ cost).
- **ALWAYS**: `Authenticatable` protocol for user models.

### SQL Injection Prevention
- **ALWAYS**: Fluent ORM (type-safe, parameterized).
- **NEVER**: Raw SQL with string interpolation.

### CORS
- **ALWAYS**: Specific origins in CORS configuration. NEVER `allowedOrigin: .all` with credentials.

### Input Validation
- **ALWAYS**: Validatable protocol with custom validators.
- **ALWAYS**: Content validation middleware.

## 3. SwiftUI/UIKit

### User Input
- **ALWAYS**: Sanitize/validate text input before processing or storage.
- **ALWAYS**: Use secure text fields (`SecureField`) for passwords.

### WebView
- **NEVER**: Load untrusted URLs without validation.
- **ALWAYS**: Disable JavaScript if not needed (`WKWebViewConfiguration`).

## 4. Error Handling

- **ALWAYS**: Generic error messages to users. Log details server-side.
- **NEVER**: Display stack traces, internal paths, or sensitive data in alerts/UI.

## 5. Dependency Security

- **ALWAYS**: Swift Package Manager with version pinning.
- **ALWAYS**: Audit dependencies regularly.

## AI Self-Check

Before generating Swift code:
- [ ] Keychain for sensitive data (not UserDefaults)?
- [ ] ATS enabled (HTTPS only)?
- [ ] BCrypt for passwords (Vapor)?
- [ ] Fluent ORM (no string interpolation in SQL)?
- [ ] Certificate pinning for critical APIs?
- [ ] SecureField for password inputs?
- [ ] File Protection API for sensitive files?
- [ ] Generic error messages to users?

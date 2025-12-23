# Swift Security

> **Scope**: Swift-specific security practices (iOS, macOS, Vapor)
> **Extends**: general/security.md
> **Applies to**: *.swift files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Keychain for sensitive data (iOS/macOS)
> **ALWAYS**: Use prepared statements or ORM (Core Data, Vapor)
> **ALWAYS**: Enable App Transport Security (ATS)
> **ALWAYS**: Validate all user input
> **ALWAYS**: Use HTTPS/TLS
> 
> **NEVER**: Store secrets in UserDefaults or plist files
> **NEVER**: Use string interpolation for SQL queries
> **NEVER**: Disable certificate validation
> **NEVER**: Log sensitive data
> **NEVER**: Use deprecated cryptography APIs

## 1. iOS/macOS Security

### Keychain Storage

```swift
// âœ… CORRECT - Keychain wrapper
import Security

class KeychainManager {
    
    enum KeychainError: Error {
        case itemNotFound
        case duplicateItem
        case unexpectedError(status: OSStatus)
    }
    
    func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateItem
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedError(status: status)
        }
    }
    
    func retrieve(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }
        
        guard let data = result as? Data else {
            throw KeychainError.unexpectedError(status: errSecInvalidData)
        }
        
        return data
    }
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedError(status: status)
        }
    }
}

// âŒ WRONG - UserDefaults for sensitive data
UserDefaults.standard.set(authToken, forKey: \"token\")  // Plaintext!
```

### Network Security (ATS)

```swift
// âœ… CORRECT - Info.plist ATS configuration
// Only allow HTTPS by default
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>

// âŒ WRONG - Disable ATS (allows HTTP)
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>  <!-- DO NOT DO THIS -->
</dict>
```

## AI Self-Check

Before generating Swift code, verify:
- [ ] Keychain used for sensitive data?
- [ ] ATS enabled (HTTPS only)?
- [ ] Core Data or prepared statements for SQL?
- [ ] Input validation on all user input?
- [ ] Passwords hashed (never stored plaintext)?
- [ ] Certificate pinning for critical APIs?
- [ ] No sensitive data in UserDefaults?
- [ ] Error messages don't expose internals?
- [ ] Dependencies up-to-date?

---

**Swift Security: Use Keychain, never UserDefaults for secrets. Enable ATS.**

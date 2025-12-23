# Dart/Flutter Security

> **Scope**: Dart and Flutter-specific security practices
> **Extends**: general/security.md
> **Applies to**: *.dart files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use flutter_secure_storage for sensitive data
> **ALWAYS**: Use parameterized queries (sqflite, drift)
> **ALWAYS**: Validate all user input
> **ALWAYS**: Use HTTPS for all network requests
> **ALWAYS**: Enable certificate pinning for sensitive APIs
> 
> **NEVER**: Store secrets in SharedPreferences
> **NEVER**: Use string interpolation for SQL
> **NEVER**: Disable certificate validation
> **NEVER**: Log sensitive data
> **NEVER**: Include API keys in source code

## 1. Flutter Secure Storage

```dart
// âœ… CORRECT - Secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}

// âŒ WRONG - SharedPreferences for sensitive data
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', authToken);  // Plaintext!
```

## AI Self-Check

Before generating Dart/Flutter code, verify:
- [ ] flutter_secure_storage for sensitive data?
- [ ] Parameterized SQL queries?
- [ ] Input validation on all user input?
- [ ] HTTPS enforced?
- [ ] Certificate pinning configured?
- [ ] No API keys hardcoded?
- [ ] Error messages don't expose internals?
- [ ] Dependencies up-to-date?

---

**Flutter Security: Use flutter_secure_storage, never SharedPreferences for secrets. Enable HTTPS.**

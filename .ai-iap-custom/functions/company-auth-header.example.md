---
title: Company Auth Header Patterns (Example)
category: Security
difficulty: beginner
purpose: Add the company auth header consistently for internal API calls
when_to_use:
  - Calling internal APIs
  - Service-to-service requests
  - Mobile app API requests
languages:
  typescript:
    - name: fetch header (Built-in)
      library: javascript-core
      recommended: true
    - name: axios interceptor
      library: axios
  python:
    - name: httpx client header
      library: httpx
      recommended: true
    - name: requests session header
      library: requests
  csharp:
    - name: HttpClient default header
      library: System.Net.Http
      recommended: true
best_practices:
  do:
    - Read tokens from environment or secure storage
    - Use a single shared client per service
  dont:
    - Hardcode tokens in source code
    - Log tokens or headers containing secrets
tags: [auth, headers, internal-api]
updated: 2026-01-09
---

## TypeScript

### fetch header (Built-in)
```typescript
const response = await fetch(url, {
  headers: { Authorization: `Bearer ${token}` },
});
```

### axios interceptor
```typescript
import axios from 'axios';

const client = axios.create();
client.interceptors.request.use((config) => {
  config.headers = config.headers ?? {};
  config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

---

## Python

### httpx client header
```python
import httpx

client = httpx.Client(headers={"Authorization": f"Bearer {token}"})
resp = client.get(url)
```

### requests session header
```python
import requests

session = requests.Session()
session.headers["Authorization"] = f"Bearer {token}"
resp = session.get(url)
```

---

## C#

### HttpClient default header
```csharp
using System.Net.Http.Headers;

httpClient.DefaultRequestHeaders.Authorization =
    new AuthenticationHeaderValue("Bearer", token);
```


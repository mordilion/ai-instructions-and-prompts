---
title: Money & Decimal Patterns
category: Correctness & Data Integrity
difficulty: intermediate
purpose: Avoid floating-point rounding bugs by representing money safely and consistently across services and clients
when_to_use:
  - Prices, totals, tax, discounts, invoices
  - Currency conversions and rounding
  - Persisting money amounts in databases
  - Exposing money values in APIs
languages:
  typescript:
    - name: Minor units (integer cents) (Built-in)
      library: javascript-core
      recommended: true
    - name: decimal.js
      library: decimal.js
  python:
    - name: Decimal (Built-in)
      library: decimal (built-in)
      recommended: true
  java:
    - name: BigDecimal (Built-in)
      library: java.math (built-in)
      recommended: true
  csharp:
    - name: decimal (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Minor units (integer cents) (Built-in)
      library: php-core
      recommended: true
    - name: BCMath (extension)
      library: ext-bcmath
  kotlin:
    - name: BigDecimal (Built-in)
      library: java.math (built-in)
      recommended: true
  swift:
    - name: Decimal (Built-in)
      library: Foundation
      recommended: true
  dart:
    - name: Minor units (integer cents) (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Store amounts in minor units (e.g., cents) in DB and APIs
  - Apply rounding explicitly at boundaries (display, invoice, settlement)
  - Avoid float/double for money math
best_practices:
  do:
    - Store currency as ISO 4217 code alongside amount
    - Use integer minor units for storage and transport when possible
    - Use explicit rounding mode (half-up/half-even) when quantizing/formatting
    - Validate currency exponent (minor unit digits) per currency
  dont:
    - Use float/double for prices or totals
    - Round repeatedly at each operation (round once at defined boundary)
    - Mix currencies without explicit conversion rules
related_functions:
  - input-validation.md
  - database-query.md
tags: [money, decimals, rounding, currency, float, precision]
updated: 2026-01-16
---

## TypeScript

### Minor units (integer cents) (Built-in)
```typescript
type Money = { cents: number; currency: string };

export function add(a: Money, b: Money): Money {
  if (a.currency !== b.currency) throw new Error('currency_mismatch');
  return { cents: a.cents + b.cents, currency: a.currency };
}

export function format(m: Money): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: m.currency })
    .format(m.cents / 100);
}
```

### decimal.js
```typescript
import Decimal from 'decimal.js';

const total = new Decimal('19.99').plus('2.50').toDecimalPlaces(2, Decimal.ROUND_HALF_UP);
```

---

## Python

### Decimal (Built-in)
```python
from decimal import Decimal, ROUND_HALF_UP

def money(value: str) -> Decimal:
    return Decimal(value).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

total = money("19.99") + money("2.50")
```

---

## Java

### BigDecimal (Built-in)
```java
import java.math.BigDecimal;
import java.math.RoundingMode;

BigDecimal a = new BigDecimal("19.99");
BigDecimal b = new BigDecimal("2.50");
BigDecimal total = a.add(b).setScale(2, RoundingMode.HALF_UP);
```

---

## C#

### decimal (Built-in)
```csharp
using System;

decimal a = 19.99m;
decimal b = 2.50m;
decimal total = Math.Round(a + b, 2, MidpointRounding.AwayFromZero);
```

---

## PHP

### Minor units (integer cents) (Built-in)
```php
<?php

function addMoney(array $a, array $b): array {
    if ($a['currency'] !== $b['currency']) { throw new RuntimeException('currency_mismatch'); }
    return ['cents' => $a['cents'] + $b['cents'], 'currency' => $a['currency']];
}

function formatMoney(array $m): string {
    $units = intdiv($m['cents'], 100);
    $cents = abs($m['cents'] % 100);
    return sprintf('%s %d.%02d', $m['currency'], $units, $cents);
}
```

### BCMath (extension)
```php
<?php

$total = bcadd('19.99', '2.50', 2); // "22.49"
```

---

## Kotlin

### BigDecimal (Built-in)
```kotlin
import java.math.BigDecimal
import java.math.RoundingMode

val total = BigDecimal("19.99").add(BigDecimal("2.50")).setScale(2, RoundingMode.HALF_UP)
```

---

## Swift

### Decimal (Built-in)
```swift
import Foundation

let a = Decimal(string: "19.99")!
let b = Decimal(string: "2.50")!
let total = a + b
```

---

## Dart

### Minor units (integer cents) (Built-in)
```dart
class Money {
  final int cents;
  final String currency;
  const Money(this.cents, this.currency);
}

Money add(Money a, Money b) {
  if (a.currency != b.currency) throw Exception('currency_mismatch');
  return Money(a.cents + b.cents, a.currency);
}
```

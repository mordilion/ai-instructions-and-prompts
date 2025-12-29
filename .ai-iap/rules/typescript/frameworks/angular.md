# Angular Framework

> **Scope**: Apply these rules when working with Angular 14+ applications
> **Applies to**: .ts files in Angular projects
> **Extends**: typescript/architecture.md, typescript/code-style.md
> **Precedence**: Framework rules OVERRIDE TypeScript rules for Angular-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use standalone components (Angular 14+, NOT NgModules for new code)
> **ALWAYS**: Inject services via constructor (dependency injection required)
> **ALWAYS**: Use OnPush change detection (performance)
> **ALWAYS**: Use async pipe for observables (automatic subscription management)
> **ALWAYS**: Unsubscribe from subscriptions in ngOnDestroy (prevent memory leaks)
> 
> **NEVER**: Use NgModules in new code (legacy pattern, use standalone)
> **NEVER**: Manually subscribe without unsubscribing (memory leak)
> **NEVER**: Mutate inputs directly (one-way data flow)
> **NEVER**: Use `any` type (breaks type safety)
> **NEVER**: Put business logic in components (belongs in services)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Standalone Components | Always (Angular 14+) | `standalone: true`, `imports: []` |
| OnPush Change Detection | Always (performance) | `changeDetection: ChangeDetectionStrategy.OnPush` |
| async Pipe | Observable in template | `{{ observable$ | async }}` |
| Signals | Reactive state (Angular 16+) | `signal()`, `computed()`, `effect()` |
| RxJS | Async operations, streams | `Observable`, `Subject`, operators |

## Core Patterns

### Standalone Component (REQUIRED)
```typescript
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-card',
  standalone: true,  // Angular 14+
  imports: [CommonModule],  // Import dependencies
  changeDetection: ChangeDetectionStrategy.OnPush,  // Performance
  template: `
    <div class="card">
      <h3>{{ user.name }}</h3>
      <button (click)="onDelete()">Delete</button>
    </div>
  `,
  styles: [`
    .card { padding: 1rem; border: 1px solid #ccc; }
  `]
})
export class UserCardComponent {
  @Input({ required: true }) user!: User;
  @Output() delete = new EventEmitter<void>();
  
  onDelete() {
    this.delete.emit();
  }
}
```

### Service with DI
```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })  // Singleton
export class UserService {
  private apiUrl = '/api/users';
  
  constructor(private http: HttpClient) {}
  
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }
  
  createUser(user: CreateUserDto): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }
}
```

### Component with Service & Observables
```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { UserService } from './user.service';
import { Subject, takeUntil } from 'rxjs';

@Component({
  selector: 'app-user-list',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div *ngFor="let user of users$ | async">
      {{ user.name }}
    </div>
  `
})
export class UserListComponent implements OnInit, OnDestroy {
  users$ = this.userService.getUsers();  // Observable
  private destroy$ = new Subject<void>();
  
  constructor(private userService: UserService) {}
  
  ngOnInit() {
    // If manual subscription needed:
    this.users$.pipe(
      takeUntil(this.destroy$)  // Auto-unsubscribe
    ).subscribe(users => console.log(users));
  }
  
  ngOnDestroy() {
    this.destroy$.next();  // Trigger unsubscribe
    this.destroy$.complete();
  }
}
```

### Signals (Angular 16+)
```typescript
import { Component, signal, computed } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <div>
      <p>Count: {{ count() }}</p>
      <p>Doubled: {{ doubled() }}</p>
      <button (click)="increment()">+</button>
    </div>
  `
})
export class CounterComponent {
  count = signal(0);  // Reactive state
  doubled = computed(() => this.count() * 2);  // Derived state
  
  increment() {
    this.count.update(n => n + 1);
  }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Using NgModules** | `@NgModule()` for new code | `standalone: true` | NgModules are legacy |
| **Manual Subscribe Without Unsubscribe** | `obs.subscribe()` without cleanup | `async` pipe or `takeUntil()` | Memory leak |
| **Mutating Inputs** | `this.user.name = 'x'` | Emit event for parent update | Breaks one-way data flow |
| **No OnPush** | Default change detection | `ChangeDetectionStrategy.OnPush` | Performance degradation |
| **Business Logic in Component** | Component does API calls, logic | Service handles logic | Untestable, unmaintainable |

### Anti-Pattern: NgModules (LEGACY, FORBIDDEN in new code)
```typescript
// ❌ WRONG - NgModule (legacy Angular pattern)
@NgModule({
  declarations: [UserComponent],
  imports: [CommonModule],
  exports: [UserComponent]
})
export class UserModule { }

// ✅ CORRECT - Standalone component (Angular 14+)
@Component({
  selector: 'app-user',
  standalone: true,
  imports: [CommonModule]
})
export class UserComponent { }
```

### Anti-Pattern: Manual Subscribe Without Cleanup (MEMORY LEAK)
```typescript
// ❌ WRONG - Memory leak
export class UserComponent implements OnInit {
  ngOnInit() {
    this.userService.getUsers().subscribe(users => {
      this.users = users;  // NEVER cleaned up!
    });
  }
}

// ✅ CORRECT - Use async pipe
template: `<div *ngFor="let user of users$ | async">...</div>`
users$ = this.userService.getUsers();

// ✅ CORRECT - Manual with takeUntil
private destroy$ = new Subject<void>();

ngOnInit() {
  this.userService.getUsers()
    .pipe(takeUntil(this.destroy$))
    .subscribe(users => this.users = users);
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

## AI Self-Check (Verify BEFORE generating Angular code)

- [ ] Using standalone components? (`standalone: true`, NOT NgModules)
- [ ] OnPush change detection? (`ChangeDetectionStrategy.OnPush`)
- [ ] Using async pipe for observables? (Avoid manual subscribe)
- [ ] Services injected via constructor? (Dependency injection)
- [ ] Unsubscribing in ngOnDestroy? (If manual subscribe)
- [ ] Never mutating @Input properties? (Emit events instead)
- [ ] Business logic in services? (NOT in components)
- [ ] Using signals for reactive state? (Angular 16+)
- [ ] Inputs/Outputs properly typed? (No `any`)
- [ ] Following Angular style guide?

## Lifecycle Hooks

| Hook | Purpose | Use Case |
|------|---------|----------|
| ngOnInit | Initialization | Fetch data, setup subscriptions |
| ngOnDestroy | Cleanup | Unsubscribe, clear timers |
| ngOnChanges | Input changes | React to @Input changes |
| ngAfterViewInit | View ready | Access ViewChild |

## Directives

```typescript
// Structural directives
*ngIf="condition"
*ngFor="let item of items; trackBy: trackByFn"
*ngSwitch

// Attribute directives
[class.active]="isActive"
[style.color]="color"
(click)="handler()"
[(ngModel)]="value"  // Two-way binding
```

## Key Libraries

- **RxJS**: `Observable`, `Subject`, operators (`map`, `filter`, `switchMap`)
- **Signals**: `signal()`, `computed()`, `effect()` (Angular 16+)
- **HttpClient**: `get()`, `post()`, `put()`, `delete()`
- **Router**: `RouterModule`, `RouterLink`, `ActivatedRoute`

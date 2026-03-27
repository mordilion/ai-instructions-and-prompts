# Ktor Framework

> **Scope**: Ktor applications  
> **Applies to**: Kotlin files in Ktor projects
> **Extends**: kotlin/architecture.md, kotlin/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use suspend functions for I/O
> **ALWAYS**: Use content negotiation for JSON
> **ALWAYS**: Use routing DSL
> **ALWAYS**: Use DI (Koin recommended)
> **ALWAYS**: Handle errors with StatusPages
> 
> **NEVER**: Use blocking I/O in handlers
> **NEVER**: Skip authentication
> **NEVER**: Use global mutable state

## Core Patterns

### Setup

```kotlin
fun Application.module() {
    install(ContentNegotiation) { json() }
    install(StatusPages) {
        exception<Throwable> { call, cause ->
            call.respondText("Error: ${cause.message}", status = HttpStatusCode.InternalServerError)
        }
    }
    routing { userRoutes() }
}
```

### Routing

```kotlin
fun Route.userRoutes() {
    route("/users") {
        get {
            call.respond(userService.getAll())
        }
        
        get("/{id}") {
            val id = call.parameters["id"]?.toIntOrNull()
                ?: return@get call.respond(HttpStatusCode.BadRequest)
            val user = userService.getById(id)
                ?: return@get call.respond(HttpStatusCode.NotFound)
            call.respond(user)
        }
        
        post {
            val user = call.receive<CreateUserRequest>()
            val created = userService.create(user)
            call.respond(HttpStatusCode.Created, created)
        }
    }
}
```

### Service

```kotlin
class UserService(private val repository: UserRepository) {
    suspend fun getAll(): List<User> = repository.findAll()
    
    suspend fun getById(id: Int): User? = repository.findById(id)
    
    suspend fun create(request: CreateUserRequest): User {
        val user = User(name = request.name, email = request.email)
        return repository.save(user)
    }
}
```

### DI (Koin)

```kotlin
val appModule = module {
    single { DatabaseFactory }
    single { UserRepository(get()) }
    single { UserService(get()) }
}

fun Application.main() {
    install(Koin) { modules(appModule) }
    module()
}
```

### Authentication

```kotlin
install(Authentication) {
    jwt("auth-jwt") {
        verifier(makeJwtVerifier())
        validate { credential ->
            if (credential.payload.getClaim("email").asString() != "") {
                JWTPrincipal(credential.payload)
            } else null
        }
    }
}

routing {
    authenticate("auth-jwt") {
        get("/protected") {
            call.respondText("Protected content")
        }
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Blocking I/O** | `Thread.sleep()` | `delay()` |
| **No Error Handling** | Raw exceptions | StatusPages |
| **No DI** | `UserService()` | Koin injection |
| **No Auth** | Open endpoints | Authentication |

## AI Self-Check

- [ ] Using suspend functions?
- [ ] Content negotiation?
- [ ] Routing DSL?
- [ ] DI configured?
- [ ] StatusPages for errors?
- [ ] Authentication setup?
- [ ] No blocking I/O?
- [ ] Proper error responses?

## Key Features

| Feature | Purpose |
|---------|---------|
| Routing DSL | Route definition |
| Content Negotiation | JSON serialization |
| StatusPages | Error handling |
| Koin | DI |
| Authentication | Security |

## Best Practices

**MUST**: suspend functions, content negotiation, routing DSL, DI, error handling
**SHOULD**: Koin, authentication, middleware, validation
**AVOID**: Blocking I/O, global state, no error handling

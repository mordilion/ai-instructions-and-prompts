# PHP Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for PHP projects

## Critical Requirements

> **ALWAYS**: Detect PHP version from `composer.json` or `.php-version`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Use your team's workflow for branching and commits (adapt as needed)
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for Git, commits, Docker, CI/CD.

## Tech Stack

**Required**:
- **Test Framework**: PHPUnit
- **Assertions**: Built-in PHPUnit assertions
- **Mocking**: PHPUnit mocks or Mockery
- **Code Coverage**: XDebug or PCOV
- **Laravel Testing**: Pest (optional, modern alternative)
- **Runtime**: Match detected PHP version

**Forbidden**:
- PHPSpec (migrate if found)
- SimpleTest (deprecated)

## Infrastructure Templates

> **ALWAYS**: Replace `{PHP_VERSION}` with detected version before creating files

**File**: `docker/Dockerfile.tests`
```dockerfile
FROM php:{PHP_VERSION}-cli
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP dependencies
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader

# Copy application
COPY . .
RUN composer dump-autoload --optimize

# Create test directories
RUN mkdir -p /test-results /coverage
```

**File**: `docker/docker-compose.tests.yml`
```yaml
services:
  tests:
    build:
      context: ..
      dockerfile: docker/Dockerfile.tests
    command: vendor/bin/phpunit --coverage-html=/coverage --log-junit=/test-results/junit.xml
    volumes:
      - ../test-results:/test-results
      - ../coverage:/coverage
    environment:
      XDEBUG_MODE: coverage
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

**GitHub Actions**:
```yaml
- name: Run Tests
  run: |
    composer install
    vendor/bin/phpunit --coverage-clover coverage.xml
  env:
    PHP_VERSION: {PHP_VERSION}
```

**GitLab CI**:
```yaml
test:
  image: php:{PHP_VERSION}-cli
  before_script:
    - apt-get update && apt-get install -y git unzip
    - curl -sS https://getcomposer.org/installer | php
    - php composer.phar install
  script:
    - vendor/bin/phpunit --coverage-text --coverage-cobertura=coverage.xml
  artifacts:
    reports:
      junit: tests/_output/report.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```

## Implementation Phases

> **For each phase**: Use your team's workflow

### Phase 1: Analysis

**Objective**: Understand project structure and test requirements

1. Detect PHP version from `composer.json`
2. Identify framework (Laravel/Symfony/WordPress/None)
3. Analyze existing test setup

**Deliverable**: Testing strategy documented

### Phase 2: Infrastructure (Optional)

**Objective**: Set up test infrastructure (skip if using cloud CI/CD)

1. Create Docker test files (if using Docker)
2. Add/update CI/CD pipeline test step
3. Configure test reporting

**Deliverable**: Tests can run in CI/CD

### Phase 3: Framework Setup

**Objective**: Install and configure PHPUnit

1. Add dependencies: PHPUnit, Mockery, Faker
2. Create `phpunit.xml` configuration
3. Run `composer install`

**Deliverable**: Test framework ready

### Phase 4: Test Structure

**Objective**: Establish test directory organization

1. Create test structure: `tests/Unit/`, `Integration/`, `Helpers/`
2. Create base test class: `TestCase.php`
3. Set up test helpers/factories

**Deliverable**: Test structure in place

### Phase 5: Test Implementation (Iterative)

**Objective**: Write tests for all components

**For each component**:
1. Understand component behavior
2. Write tests (unit/integration/feature)
3. Ensure tests pass
4. Log bugs found (don't fix production code)

**Continue until**: All critical components tested

## Test Patterns

### Basic PHPUnit Pattern
```php
<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;
use App\Services\UserService;

class UserServiceTest extends TestCase
{
    private UserService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new UserService();
    }

    public function test_create_user_with_valid_data(): void
    {
        // Given
        $email = 'john@example.com';
        $name = 'John Doe';

        // When
        $user = $this->service->createUser($email, $name);

        // Then
        $this->assertEquals($email, $user->email);
        $this->assertEquals($name, $user->name);
    }

    public function test_create_user_throws_exception_for_invalid_email(): void
    {
        // Given
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid email');

        // When/Then
        $this->service->createUser('invalid', 'John Doe');
    }
}
```

### Mockery Pattern
```php
<?php

namespace Tests\Unit;

use Mockery;
use PHPUnit\Framework\TestCase;
use App\Services\UserService;
use App\Repositories\UserRepository;

class UserServiceTest extends TestCase
{
    public function test_find_user_calls_repository(): void
    {
        // Given
        $repository = Mockery::mock(UserRepository::class);
        $repository->shouldReceive('findById')
            ->once()
            ->with(1)
            ->andReturn(['id' => 1, 'name' => 'John']);

        $service = new UserService($repository);

        // When
        $user = $service->findById(1);

        // Then
        $this->assertEquals('John', $user['name']);
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }
}
```

### Laravel Feature Test Pattern
```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_get_user_returns_user_data(): void
    {
        // Given
        $user = User::factory()->create([
            'name' => 'John Doe',
            'email' => 'john@example.com'
        ]);

        // When
        $response = $this->getJson("/api/users/{$user->id}");

        // Then
        $response->assertStatus(200)
            ->assertJson([
                'id' => $user->id,
                'name' => 'John Doe',
                'email' => 'john@example.com'
            ]);
    }

    public function test_create_user_stores_in_database(): void
    {
        // Given
        $data = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123'
        ];

        // When
        $response = $this->postJson('/api/users', $data);

        // Then
        $response->assertStatus(201);
        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com'
        ]);
    }
}
```

### Pest Pattern (Laravel Alternative)
```php
<?php

use App\Models\User;

it('returns user data', function () {
    // Given
    $user = User::factory()->create(['name' => 'John Doe']);

    // When
    $response = $this->getJson("/api/users/{$user->id}");

    // Then
    $response->assertStatus(200)
        ->assertJson(['name' => 'John Doe']);
});

it('creates user in database', function () {
    // Given
    $data = [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123'
    ];

    // When
    $response = $this->postJson('/api/users', $data);

    // Then
    $response->assertStatus(201);
    expect($user = User::where('email', $data['email'])->first())
        ->not->toBeNull()
        ->name->toBe('John Doe');
});
```

### Symfony Test Pattern
```php
<?php

namespace App\Tests\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class UserControllerTest extends WebTestCase
{
    public function testGetUser(): void
    {
        // Given
        $client = static::createClient();

        // When
        $client->request('GET', '/api/users/1');

        // Then
        $this->assertResponseIsSuccessful();
        $this->assertJson($client->getResponse()->getContent());
        
        $data = json_decode($client->getResponse()->getContent(), true);
        $this->assertEquals(1, $data['id']);
    }
}
```

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected PHP version + framework + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (iterative, multi-phase)  
> **When to use**: When establishing testing infrastructure in a PHP project

### Complete Implementation Prompt

```
CONTEXT:
You are implementing comprehensive PHP testing infrastructure for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect PHP version from composer.json
- ALWAYS detect framework (Laravel, Symfony, plain PHP)
- ALWAYS match detected version in Docker images, pipelines, and environments
- NEVER fix production code bugs found during testing (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow (no prescribed branch names or commit patterns)

TECH STACK TO CHOOSE:
Test Framework (choose one):
- PHPUnit ⭐ (recommended) - Industry standard
- Codeception - Full-stack testing
- Pest - Laravel-friendly, elegant syntax
- PHPSpec - BDD-style specification testing

Mocking (choose one):
- PHPUnit mocks ⭐ (built-in)
- Mockery - More expressive mocking
- Prophecy - Highly opinionated mocking

---

PHASE 1 - ANALYSIS:
Objective: Understand project structure and choose test framework

1. Detect PHP version from composer.json
2. Detect framework (Laravel, Symfony, or none)
3. Document in process-docs/PROJECT_MEMORY.md
4. Identify existing test framework or choose based on project
5. Analyze current test infrastructure (if any)
6. Report findings and proposed framework choices

Deliverable: Testing strategy documented, framework chosen

---

PHASE 2 - INFRASTRUCTURE (Optional - skip if using cloud CI/CD):
Objective: Set up test infrastructure

1. Create Dockerfile.tests with detected PHP version
2. Create docker-compose.tests.yml
3. Add/update CI/CD pipeline test step
4. Configure phpunit.xml or pest.php
5. Configure code coverage (PHPUnit --coverage)

Deliverable: Tests can run in CI/CD environment

---

PHASE 3 - TEST PROJECTS:
Objective: Create test project structure

1. Create tests/ directory structure
2. For Laravel: Use artisan make:test commands
3. Implement shared test utilities and traits
4. Set up test database configuration
5. Create factories and seeders for test data

Deliverable: Test project structure in place

---

PHASE 4 - TEST IMPLEMENTATION (Iterative):
Objective: Write tests for all components

For each component:
1. Identify component to test
2. Write unit tests (isolated, fast)
3. Write feature/integration tests if applicable
4. For Laravel: Use database transactions for cleanup
5. Run tests - must pass
6. If bugs found: Log to LOGIC_ANOMALIES.md (DON'T fix code)
7. Update STATUS-DETAILS.md
8. Propose commit
9. Repeat for next component

Deliverable: Comprehensive test coverage

---

DOCUMENTATION (create in process-docs/):
- STATUS-DETAILS.md: Component test checklist
- PROJECT_MEMORY.md: Detected PHP version, framework, chosen test framework, lessons learned
- LOGIC_ANOMALIES.md: Bugs found (audit only)

---

START: Execute Phase 1. Analyze project, detect PHP version and framework, propose test framework choices.
```


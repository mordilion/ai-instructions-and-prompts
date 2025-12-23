# PHP Testing Implementation Process

> **ALWAYS**: Follow phases sequentially. One branch per phase. Atomic commits only.

## Critical Requirements

> **ALWAYS**: Detect PHP version from `composer.json` or `.php-version`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Create new branch for each phase: `poc/test-establishing/{phase-name}`
> **NEVER**: Combine multiple phases in one commit
> **NEVER**: Fix production code bugs found during testing (log only)

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

### Phase 1: Analysis
**Branch**: `poc/test-establishing/init-analysis`

1. Initialize `process-docs/` (STATUS-DETAILS.md, PROJECT_MEMORY.md, LOGIC_ANOMALIES.md)
2. Detect PHP version from `composer.json` → Document in PROJECT_MEMORY.md
3. Detect framework (Laravel/Symfony/WordPress/None)
4. Analyze existing test setup
5. Propose commit → Wait for user

### Phase 2: Infrastructure
**Branch**: `poc/test-establishing/docker-infra`

1. Create `docker/Dockerfile.tests` with detected version
2. Create `docker/docker-compose.tests.yml`
3. Merge CI/CD pipeline step (don't overwrite)
4. Propose commit → Wait for user

### Phase 3: Framework Setup
**Branch**: `poc/test-establishing/framework-setup`

1. Add dependencies to `composer.json`:
   ```json
   {
     "require-dev": {
       "phpunit/phpunit": "^10.5",
       "mockery/mockery": "^1.6",
       "fakerphp/faker": "^1.23"
     }
   }
   ```
2. Create `phpunit.xml`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <phpunit bootstrap="vendor/autoload.php"
            colors="true"
            stopOnFailure="false">
       <testsuites>
           <testsuite name="Unit">
               <directory>tests/Unit</directory>
           </testsuite>
           <testsuite name="Integration">
               <directory>tests/Integration</directory>
           </testsuite>
       </testsuites>
       <coverage>
           <include>
               <directory suffix=".php">src</directory>
           </include>
       </coverage>
   </phpunit>
   ```
3. Run `composer install`
4. Propose commit → Wait for user

### Phase 4: Test Structure
**Branch**: `poc/test-establishing/project-skeleton`

1. Create test directory structure:
   ```
   tests/
   ├── Unit/              # Unit tests
   ├── Integration/       # Integration tests
   ├── Feature/          # Feature tests (Laravel)
   └── Helpers/          # Test utilities
       ├── TestCase.php
       └── Factories/
   ```
2. Implement base patterns:
   - `tests/Helpers/TestCase.php`
   - `tests/Helpers/Factories/UserFactory.php`
   - If Laravel: Extend framework's TestCase
3. Propose commit → Wait for user

### Phase 5: Test Implementation (Loop)
**Branch**: `poc/test-establishing/test-{component}` (new branch per component)

1. Read next untested component from STATUS-DETAILS.md
2. Understand intent and behavior
3. Write tests following patterns
4. Run tests locally → Must pass
5. If bugs found → Log to LOGIC_ANOMALIES.md (DON'T fix code)
6. Update STATUS-DETAILS.md
7. Propose commit: `feat(test): add tests for {Component}`
8. Wait for user confirmation → Repeat for next component

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

## Usage

**Initial**:
```
Act as Senior SDET. Start PHP testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect PHP version, analyze project, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```


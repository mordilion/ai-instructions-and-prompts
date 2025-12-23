# Dart/Flutter Testing Implementation Process

> **ALWAYS**: Follow phases sequentially. One branch per phase. Atomic commits only.

## Critical Requirements

> **ALWAYS**: Detect Dart/Flutter version from `pubspec.yaml`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Create new branch for each phase: `poc/test-establishing/{phase-name}`
> **NEVER**: Combine multiple phases in one commit
> **NEVER**: Fix production code bugs found during testing (log only)

## Tech Stack

**Required**:
- **Test Framework**: Built-in `test` package
- **Widget Testing**: Flutter `flutter_test`
- **Integration Testing**: `integration_test` package
- **Mocking**: `mockito` or `mocktail`
- **BLoC Testing**: `bloc_test` (if using BLoC)
- **Runtime**: Match detected Dart/Flutter version

**Test Types**:
1. **Unit Tests**: Pure Dart logic
2. **Widget Tests**: UI component testing
3. **Integration Tests**: Full app testing

## Infrastructure Templates

> **ALWAYS**: Replace `{FLUTTER_VERSION}` with detected version before creating files

**File**: `docker/Dockerfile.tests`
```dockerfile
FROM cirrusci/flutter:{FLUTTER_VERSION}
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy application
COPY . .

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
    command: flutter test --coverage --machine > /test-results/test-results.json
    volumes:
      - ../test-results:/test-results
      - ../coverage:/app/coverage
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

**GitHub Actions**:
```yaml
- name: Run Tests
  run: |
    flutter test --coverage
    flutter test --machine > test-results.json
  env:
    FLUTTER_VERSION: {FLUTTER_VERSION}
```

**GitLab CI**:
```yaml
test:
  image: cirrusci/flutter:{FLUTTER_VERSION}
  script:
    - flutter pub get
    - flutter test --coverage --machine > test-results.json
  artifacts:
    reports:
      junit: test-results.xml
    paths:
      - coverage/lcov.info
```

## Implementation Phases

### Phase 1: Analysis
**Branch**: `poc/test-establishing/init-analysis`

1. Initialize `process-docs/` (STATUS-DETAILS.md, PROJECT_MEMORY.md, LOGIC_ANOMALIES.md)
2. Detect Dart/Flutter version from `pubspec.yaml` → Document in PROJECT_MEMORY.md
3. Detect state management (BLoC/Riverpod/GetX/Provider)
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

1. Add dependencies to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     test: ^1.24.0
     mockito: ^5.4.0
     build_runner: ^2.4.0  # For mockito code generation
     bloc_test: ^9.1.0     # If using BLoC
     mocktail: ^1.0.0      # Alternative to mockito
     integration_test:
       sdk: flutter
   ```
2. Run `flutter pub get`
3. Create test configuration files
4. Propose commit → Wait for user

### Phase 4: Test Structure
**Branch**: `poc/test-establishing/project-skeleton`

1. Create test directory structure:
   ```
   test/
   ├── unit/              # Unit tests
   │   ├── models/
   │   ├── services/
   │   └── repositories/
   ├── widget/            # Widget tests
   │   ├── screens/
   │   └── widgets/
   ├── helpers/          # Test utilities
   │   ├── test_helpers.dart
   │   └── mock_data.dart
   └── fixtures/         # Test data
   
   integration_test/
   └── app_test.dart     # Integration tests
   ```
2. Implement base patterns:
   - `test/helpers/test_helpers.dart`
   - `test/helpers/mock_data.dart`
   - `test/helpers/pump_app.dart` (Widget test helper)
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

### Unit Test Pattern
```dart
import 'package:test/test.dart';
import 'package:your_app/services/user_service.dart';

void main() {
  group('UserService', () {
    late UserService service;

    setUp(() {
      service = UserService();
    });

    test('createUser returns user with valid data', () {
      // Given
      const email = 'john@example.com';
      const name = 'John Doe';

      // When
      final user = service.createUser(email: email, name: name);

      // Then
      expect(user.email, equals(email));
      expect(user.name, equals(name));
    });

    test('createUser throws exception for invalid email', () {
      // Given
      const invalidEmail = 'invalid';

      // When/Then
      expect(
        () => service.createUser(email: invalidEmail, name: 'John'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
```

### Mockito Pattern
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:your_app/repositories/user_repository.dart';
import 'package:your_app/services/user_service.dart';

// Generate mocks: flutter pub run build_runner build
@GenerateMocks([UserRepository])
import 'user_service_test.mocks.dart';

void main() {
  group('UserService with mocks', () {
    late MockUserRepository mockRepository;
    late UserService service;

    setUp(() {
      mockRepository = MockUserRepository();
      service = UserService(repository: mockRepository);
    });

    test('findById calls repository', () async {
      // Given
      final user = User(id: 1, name: 'John');
      when(mockRepository.findById(1))
          .thenAnswer((_) async => user);

      // When
      final result = await service.findById(1);

      // Then
      expect(result.name, equals('John'));
      verify(mockRepository.findById(1)).called(1);
    });
  });
}
```

### Widget Test Pattern
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/widgets/user_card.dart';
import 'package:your_app/models/user.dart';

void main() {
  group('UserCard Widget', () {
    testWidgets('displays user name and email', (tester) async {
      // Given
      const user = User(id: 1, name: 'John Doe', email: 'john@example.com');

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(user: user),
          ),
        ),
      );

      // Then
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      // Given
      const user = User(id: 1, name: 'John Doe', email: 'john@example.com');
      var tapped = false;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: user,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UserCard));
      await tester.pump();

      // Then
      expect(tapped, isTrue);
    });
  });
}
```

### BLoC Test Pattern
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:your_app/blocs/user/user_bloc.dart';

void main() {
  group('UserBloc', () {
    late UserRepository mockRepository;

    setUp(() {
      mockRepository = MockUserRepository();
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when LoadUser is added',
      build: () {
        when(mockRepository.getUsers())
            .thenAnswer((_) async => [User(id: 1, name: 'John')]);
        return UserBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [
        const UserLoading(),
        UserLoaded(users: [User(id: 1, name: 'John')]),
      ],
      verify: (_) {
        verify(mockRepository.getUsers()).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when repository throws',
      build: () {
        when(mockRepository.getUsers())
            .thenThrow(Exception('Failed to load'));
        return UserBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [
        const UserLoading(),
        const UserError(message: 'Failed to load users'),
      ],
    );
  });
}
```

### Riverpod Test Pattern
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/providers/user_provider.dart';

void main() {
  group('UserProvider', () {
    test('userProvider returns user list', () async {
      // Given
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // When
      final users = await container.read(userProvider.future);

      // Then
      expect(users, isNotEmpty);
      expect(users.first.name, isNotNull);
    });

    test('userProvider with mock repository', () async {
      // Given
      final mockRepository = MockUserRepository();
      when(mockRepository.getUsers())
          .thenAnswer((_) async => [User(id: 1, name: 'John')]);

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // When
      final users = await container.read(userProvider.future);

      // Then
      expect(users.length, equals(1));
      expect(users.first.name, equals('John'));
    });
  });
}
```

### Integration Test Pattern
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('complete user flow', (tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // When - Navigate to users screen
      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();

      // Then - Verify users are loaded
      expect(find.byType(UserCard), findsWidgets);

      // When - Tap first user
      await tester.tap(find.byType(UserCard).first);
      await tester.pumpAndSettle();

      // Then - Verify user details screen
      expect(find.text('User Details'), findsOneWidget);
    });
  });
}
```

### Golden Test Pattern (Screenshot Testing)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/widgets/user_card.dart';

void main() {
  testWidgets('UserCard matches golden file', (tester) async {
    // Given
    const user = User(id: 1, name: 'John Doe', email: 'john@example.com');

    // When
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserCard(user: user),
        ),
      ),
    );

    // Then
    await expectLater(
      find.byType(UserCard),
      matchesGoldenFile('goldens/user_card.png'),
    );
  });
}
```

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected Dart/Flutter version + state management + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage

**Initial**:
```
Act as Senior SDET. Start Flutter testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect Flutter version, analyze state management, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```


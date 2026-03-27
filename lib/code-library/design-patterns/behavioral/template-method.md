---
title: Template Method Pattern
category: Behavioral Design Pattern
difficulty: beginner
purpose: Define the skeleton of an algorithm in a base class, letting subclasses override specific steps without changing the algorithm's structure
when_to_use:
  - Testing frameworks (setup/teardown)
  - Data processing pipelines
  - Game loops and AI
  - Document generation
  - Report builders
  - Initialization sequences
languages:
  typescript:
    - name: Abstract Class Template (Built-in)
      library: javascript-core
      recommended: true
  python:
    - name: ABC Template (Built-in)
      library: python-core
      recommended: true
  java:
    - name: Abstract Class Template (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Abstract Class Template (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Abstract Class Template (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Abstract Class Template (Built-in)
      library: kotlin-stdlib
      recommended: true
  swift:
    - name: Class Template (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Abstract Class Template (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Hook methods (optional override)
  - Required steps (must override)
  - Fixed algorithm structure
  - Hollywood Principle (don't call us, we'll call you)
best_practices:
  do:
    - Keep template method final/sealed
    - Provide sensible defaults for hooks
    - Document which methods must/can be overridden
    - Keep algorithm steps cohesive
    - Use for lifecycle methods
  dont:
    - Allow template method override
    - Create too many steps (hard to follow)
    - Put business logic in template method
    - Make all steps abstract (provide defaults)
related_functions:
  - None
tags: [template-method, behavioral-pattern, inheritance, hooks, algorithm-skeleton]
updated: 2026-01-20
---

## TypeScript

### Data Processing Template
```typescript
abstract class DataProcessor {
  // Template method - defines the algorithm structure
  async process(): Promise<void> {
    this.openFile();
    const data = await this.extractData();
    const parsed = this.parseData(data);
    const analyzed = this.analyzeData(parsed);
    this.sendReport(analyzed);
    this.closeFile();
  }

  // Steps that subclasses must implement
  protected abstract extractData(): Promise<string>;
  protected abstract parseData(raw: string): any[];
  protected abstract analyzeData(data: any[]): any;

  // Hook methods with default implementation (optional override)
  protected openFile(): void {
    console.log('Opening file...');
  }

  protected closeFile(): void {
    console.log('Closing file...');
  }

  protected sendReport(results: any): void {
    console.log('Sending report:', results);
  }
}

// Concrete implementation - CSV
class CSVDataProcessor extends DataProcessor {
  protected async extractData(): Promise<string> {
    console.log('Extracting CSV data...');
    return 'name,age\nJohn,30\nJane,25';
  }

  protected parseData(raw: string): any[] {
    console.log('Parsing CSV...');
    const lines = raw.split('\n').slice(1); // Skip header
    return lines.map(line => {
      const [name, age] = line.split(',');
      return { name, age: parseInt(age) };
    });
  }

  protected analyzeData(data: any[]): any {
    console.log('Analyzing CSV data...');
    const avgAge = data.reduce((sum, p) => sum + p.age, 0) / data.length;
    return { count: data.length, averageAge: avgAge };
  }
}

// Concrete implementation - JSON
class JSONDataProcessor extends DataProcessor {
  protected async extractData(): Promise<string> {
    console.log('Extracting JSON data...');
    return '[{"name":"John","age":30},{"name":"Jane","age":25}]';
  }

  protected parseData(raw: string): any[] {
    console.log('Parsing JSON...');
    return JSON.parse(raw);
  }

  protected analyzeData(data: any[]): any {
    console.log('Analyzing JSON data...');
    const avgAge = data.reduce((sum, p) => sum + p.age, 0) / data.length;
    return { count: data.length, averageAge: avgAge };
  }

  // Override hook to customize behavior
  protected sendReport(results: any): void {
    console.log('Sending JSON report via API:', results);
  }
}

// Usage
const csvProcessor = new CSVDataProcessor();
await csvProcessor.process();

console.log('\n---\n');

const jsonProcessor = new JSONDataProcessor();
await jsonProcessor.process();
```

### Test Framework Template
```typescript
abstract class TestCase {
  // Template method
  run(): void {
    console.log(`\nRunning test: ${this.constructor.name}`);
    
    this.setUp();
    
    try {
      this.runTest();
      console.log('✓ Test passed');
    } catch (error) {
      console.log('✗ Test failed:', error);
    } finally {
      this.tearDown();
    }
  }

  // Hook methods
  protected setUp(): void {
    // Default: do nothing
  }

  protected tearDown(): void {
    // Default: do nothing
  }

  // Abstract method - must be implemented
  protected abstract runTest(): void;
}

// Concrete test
class DatabaseTest extends TestCase {
  private connection: any = null;

  protected setUp(): void {
    console.log('Setting up database connection...');
    this.connection = { connected: true };
  }

  protected runTest(): void {
    console.log('Running database test...');
    if (!this.connection?.connected) {
      throw new Error('Database not connected');
    }
    // Test logic here
  }

  protected tearDown(): void {
    console.log('Closing database connection...');
    this.connection = null;
  }
}

class APITest extends TestCase {
  protected setUp(): void {
    console.log('Setting up API client...');
  }

  protected runTest(): void {
    console.log('Running API test...');
    // Test logic here
  }
}

// Usage
const dbTest = new DatabaseTest();
dbTest.run();

const apiTest = new APITest();
apiTest.run();
```

---

## Python

### Data Processing Template
```python
from abc import ABC, abstractmethod
from typing import List, Any

class DataProcessor(ABC):
    # Template method
    async def process(self) -> None:
        self.open_file()
        data = await self.extract_data()
        parsed = self.parse_data(data)
        analyzed = self.analyze_data(parsed)
        self.send_report(analyzed)
        self.close_file()

    # Abstract methods - must be implemented
    @abstractmethod
    async def extract_data(self) -> str:
        pass

    @abstractmethod
    def parse_data(self, raw: str) -> List[Any]:
        pass

    @abstractmethod
    def analyze_data(self, data: List[Any]) -> Any:
        pass

    # Hook methods with default implementation
    def open_file(self) -> None:
        print("Opening file...")

    def close_file(self) -> None:
        print("Closing file...")

    def send_report(self, results: Any) -> None:
        print(f"Sending report: {results}")

# Concrete implementation - CSV
class CSVDataProcessor(DataProcessor):
    async def extract_data(self) -> str:
        print("Extracting CSV data...")
        return "name,age\nJohn,30\nJane,25"

    def parse_data(self, raw: str) -> List[dict]:
        print("Parsing CSV...")
        lines = raw.split("\n")[1:]  # Skip header
        result = []
        for line in lines:
            name, age = line.split(",")
            result.append({"name": name, "age": int(age)})
        return result

    def analyze_data(self, data: List[dict]) -> dict:
        print("Analyzing CSV data...")
        avg_age = sum(p["age"] for p in data) / len(data)
        return {"count": len(data), "averageAge": avg_age}

# Concrete implementation - JSON
class JSONDataProcessor(DataProcessor):
    async def extract_data(self) -> str:
        print("Extracting JSON data...")
        return '[{"name":"John","age":30},{"name":"Jane","age":25}]'

    def parse_data(self, raw: str) -> List[dict]:
        print("Parsing JSON...")
        import json
        return json.loads(raw)

    def analyze_data(self, data: List[dict]) -> dict:
        print("Analyzing JSON data...")
        avg_age = sum(p["age"] for p in data) / len(data)
        return {"count": len(data), "averageAge": avg_age}

    def send_report(self, results: Any) -> None:
        print(f"Sending JSON report via API: {results}")

# Usage
import asyncio

async def main():
    csv_processor = CSVDataProcessor()
    await csv_processor.process()

    print("\n---\n")

    json_processor = JSONDataProcessor()
    await json_processor.process()

asyncio.run(main())
```

---

## Java

### Data Processing Template
```java
import java.util.List;
import java.util.Map;

// Abstract class with template method
abstract class DataProcessor {
    // Template method - final to prevent override
    public final void process() {
        openFile();
        String data = extractData();
        List<Map<String, Object>> parsed = parseData(data);
        Map<String, Object> analyzed = analyzeData(parsed);
        sendReport(analyzed);
        closeFile();
    }

    // Abstract methods - must be implemented
    protected abstract String extractData();
    protected abstract List<Map<String, Object>> parseData(String raw);
    protected abstract Map<String, Object> analyzeData(List<Map<String, Object>> data);

    // Hook methods with default implementation
    protected void openFile() {
        System.out.println("Opening file...");
    }

    protected void closeFile() {
        System.out.println("Closing file...");
    }

    protected void sendReport(Map<String, Object> results) {
        System.out.println("Sending report: " + results);
    }
}

// Concrete implementation
class CSVDataProcessor extends DataProcessor {
    @Override
    protected String extractData() {
        System.out.println("Extracting CSV data...");
        return "name,age\nJohn,30\nJane,25";
    }

    @Override
    protected List<Map<String, Object>> parseData(String raw) {
        System.out.println("Parsing CSV...");
        String[] lines = raw.split("\n");
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (int i = 1; i < lines.length; i++) {
            String[] parts = lines[i].split(",");
            Map<String, Object> person = new HashMap<>();
            person.put("name", parts[0]);
            person.put("age", Integer.parseInt(parts[1]));
            result.add(person);
        }
        
        return result;
    }

    @Override
    protected Map<String, Object> analyzeData(List<Map<String, Object>> data) {
        System.out.println("Analyzing CSV data...");
        double avgAge = data.stream()
            .mapToInt(p -> (Integer) p.get("age"))
            .average()
            .orElse(0);
        
        Map<String, Object> results = new HashMap<>();
        results.put("count", data.size());
        results.put("averageAge", avgAge);
        return results;
    }
}

// Usage
DataProcessor processor = new CSVDataProcessor();
processor.process();
```

---

## C#

### Data Processing Template
```csharp
// Abstract class with template method
public abstract class DataProcessor
{
    // Template method - sealed to prevent override
    public sealed async Task ProcessAsync()
    {
        OpenFile();
        var data = await ExtractDataAsync();
        var parsed = ParseData(data);
        var analyzed = AnalyzeData(parsed);
        SendReport(analyzed);
        CloseFile();
    }

    // Abstract methods - must be implemented
    protected abstract Task<string> ExtractDataAsync();
    protected abstract List<Dictionary<string, object>> ParseData(string raw);
    protected abstract Dictionary<string, object> AnalyzeData(List<Dictionary<string, object>> data);

    // Hook methods with default implementation
    protected virtual void OpenFile()
    {
        Console.WriteLine("Opening file...");
    }

    protected virtual void CloseFile()
    {
        Console.WriteLine("Closing file...");
    }

    protected virtual void SendReport(Dictionary<string, object> results)
    {
        Console.WriteLine($"Sending report: {string.Join(", ", results)}");
    }
}

// Concrete implementation
public class CSVDataProcessor : DataProcessor
{
    protected override async Task<string> ExtractDataAsync()
    {
        Console.WriteLine("Extracting CSV data...");
        await Task.CompletedTask;
        return "name,age\nJohn,30\nJane,25";
    }

    protected override List<Dictionary<string, object>> ParseData(string raw)
    {
        Console.WriteLine("Parsing CSV...");
        var lines = raw.Split('\n').Skip(1);
        var result = new List<Dictionary<string, object>>();

        foreach (var line in lines)
        {
            var parts = line.Split(',');
            result.Add(new Dictionary<string, object>
            {
                ["name"] = parts[0],
                ["age"] = int.Parse(parts[1])
            });
        }

        return result;
    }

    protected override Dictionary<string, object> AnalyzeData(List<Dictionary<string, object>> data)
    {
        Console.WriteLine("Analyzing CSV data...");
        var avgAge = data.Average(p => (int)p["age"]);

        return new Dictionary<string, object>
        {
            ["count"] = data.Count,
            ["averageAge"] = avgAge
        };
    }
}

// Usage
var processor = new CSVDataProcessor();
await processor.ProcessAsync();
```

---

## PHP

### Data Processing Template
```php
// Abstract class with template method
abstract class DataProcessor
{
    // Template method - final to prevent override
    final public function process(): void
    {
        $this->openFile();
        $data = $this->extractData();
        $parsed = $this->parseData($data);
        $analyzed = $this->analyzeData($parsed);
        $this->sendReport($analyzed);
        $this->closeFile();
    }

    // Abstract methods - must be implemented
    abstract protected function extractData(): string;
    abstract protected function parseData(string $raw): array;
    abstract protected function analyzeData(array $data): array;

    // Hook methods with default implementation
    protected function openFile(): void
    {
        echo "Opening file...\n";
    }

    protected function closeFile(): void
    {
        echo "Closing file...\n";
    }

    protected function sendReport(array $results): void
    {
        echo "Sending report: " . json_encode($results) . "\n";
    }
}

// Concrete implementation
class CSVDataProcessor extends DataProcessor
{
    protected function extractData(): string
    {
        echo "Extracting CSV data...\n";
        return "name,age\nJohn,30\nJane,25";
    }

    protected function parseData(string $raw): array
    {
        echo "Parsing CSV...\n";
        $lines = explode("\n", $raw);
        array_shift($lines); // Remove header
        
        $result = [];
        foreach ($lines as $line) {
            [$name, $age] = explode(',', $line);
            $result[] = ['name' => $name, 'age' => (int)$age];
        }
        
        return $result;
    }

    protected function analyzeData(array $data): array
    {
        echo "Analyzing CSV data...\n";
        $avgAge = array_sum(array_column($data, 'age')) / count($data);
        
        return [
            'count' => count($data),
            'averageAge' => $avgAge
        ];
    }
}

// Usage
$processor = new CSVDataProcessor();
$processor->process();
```

---

## Kotlin

### Data Processing Template
```kotlin
// Abstract class with template method
abstract class DataProcessor {
    // Template method - open (can add 'final' to prevent override)
    suspend fun process() {
        openFile()
        val data = extractData()
        val parsed = parseData(data)
        val analyzed = analyzeData(parsed)
        sendReport(analyzed)
        closeFile()
    }

    // Abstract methods - must be implemented
    protected abstract suspend fun extractData(): String
    protected abstract fun parseData(raw: String): List<Map<String, Any>>
    protected abstract fun analyzeData(data: List<Map<String, Any>>): Map<String, Any>

    // Hook methods with default implementation
    protected open fun openFile() {
        println("Opening file...")
    }

    protected open fun closeFile() {
        println("Closing file...")
    }

    protected open fun sendReport(results: Map<String, Any>) {
        println("Sending report: $results")
    }
}

// Concrete implementation
class CSVDataProcessor : DataProcessor() {
    override suspend fun extractData(): String {
        println("Extracting CSV data...")
        return "name,age\nJohn,30\nJane,25"
    }

    override fun parseData(raw: String): List<Map<String, Any>> {
        println("Parsing CSV...")
        return raw.split("\n").drop(1).map { line ->
            val (name, age) = line.split(",")
            mapOf("name" to name, "age" to age.toInt())
        }
    }

    override fun analyzeData(data: List<Map<String, Any>>): Map<String, Any> {
        println("Analyzing CSV data...")
        val avgAge = data.map { it["age"] as Int }.average()
        return mapOf("count" to data.size, "averageAge" to avgAge)
    }
}

// Usage
suspend fun main() {
    val processor = CSVDataProcessor()
    processor.process()
}
```

---

## Swift

### Data Processing Template
```swift
// Abstract class with template method
class DataProcessor {
    // Template method - final to prevent override
    final func process() async {
        openFile()
        let data = await extractData()
        let parsed = parseData(raw: data)
        let analyzed = analyzeData(data: parsed)
        sendReport(results: analyzed)
        closeFile()
    }

    // Methods to be overridden - must be implemented in subclass
    func extractData() async -> String {
        fatalError("extractData() must be implemented by subclass")
    }

    func parseData(raw: String) -> [[String: Any]] {
        fatalError("parseData() must be implemented by subclass")
    }

    func analyzeData(data: [[String: Any]]) -> [String: Any] {
        fatalError("analyzeData() must be implemented by subclass")
    }

    // Hook methods with default implementation
    func openFile() {
        print("Opening file...")
    }

    func closeFile() {
        print("Closing file...")
    }

    func sendReport(results: [String: Any]) {
        print("Sending report: \(results)")
    }
}

// Concrete implementation
class CSVDataProcessor: DataProcessor {
    override func extractData() async -> String {
        print("Extracting CSV data...")
        return "name,age\nJohn,30\nJane,25"
    }

    override func parseData(raw: String) -> [[String: Any]] {
        print("Parsing CSV...")
        let lines = raw.split(separator: "\n").dropFirst()
        return lines.map { line in
            let parts = line.split(separator: ",")
            return [
                "name": String(parts[0]),
                "age": Int(parts[1]) ?? 0
            ]
        }
    }

    override func analyzeData(data: [[String: Any]]) -> [String: Any] {
        print("Analyzing CSV data...")
        let avgAge = data.compactMap { $0["age"] as? Int }.reduce(0, +) / data.count
        return [
            "count": data.count,
            "averageAge": avgAge
        ]
    }
}

// Usage
let processor = CSVDataProcessor()
await processor.process()
```

---

## Dart

### Data Processing Template
```dart
// Abstract class with template method
abstract class DataProcessor {
  // Template method
  Future<void> process() async {
    openFile();
    final data = await extractData();
    final parsed = parseData(data);
    final analyzed = analyzeData(parsed);
    sendReport(analyzed);
    closeFile();
  }

  // Abstract methods - must be implemented
  Future<String> extractData();
  List<Map<String, dynamic>> parseData(String raw);
  Map<String, dynamic> analyzeData(List<Map<String, dynamic>> data);

  // Hook methods with default implementation
  void openFile() {
    print('Opening file...');
  }

  void closeFile() {
    print('Closing file...');
  }

  void sendReport(Map<String, dynamic> results) {
    print('Sending report: $results');
  }
}

// Concrete implementation
class CSVDataProcessor extends DataProcessor {
  @override
  Future<String> extractData() async {
    print('Extracting CSV data...');
    return 'name,age\nJohn,30\nJane,25';
  }

  @override
  List<Map<String, dynamic>> parseData(String raw) {
    print('Parsing CSV...');
    final lines = raw.split('\n').skip(1);
    return lines.map((line) {
      final parts = line.split(',');
      return {
        'name': parts[0],
        'age': int.parse(parts[1]),
      };
    }).toList();
  }

  @override
  Map<String, dynamic> analyzeData(List<Map<String, dynamic>> data) {
    print('Analyzing CSV data...');
    final avgAge = data.map((p) => p['age'] as int).reduce((a, b) => a + b) / data.length;
    return {
      'count': data.length,
      'averageAge': avgAge,
    };
  }
}

// Usage
void main() async {
  final processor = CSVDataProcessor();
  await processor.process();
}
```

---
title: Composite Pattern
category: Structural Design Pattern
difficulty: intermediate
purpose: Compose objects into tree structures to represent part-whole hierarchies, allowing uniform treatment of individual and composite objects
when_to_use:
  - UI component trees (React, Vue, Flutter)
  - File system structures
  - Organization hierarchies
  - Menu systems
  - Document structures (paragraphs, sections)
  - Graphics systems (shapes, groups)
languages:
  typescript:
    - name: Component Composite (Built-in)
      library: javascript-core
      recommended: true
    - name: React Component Tree
      library: react
  python:
    - name: ABC Composite (Built-in)
      library: python-core
      recommended: true
  java:
    - name: Interface Composite (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Interface Composite (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Interface Composite (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Interface Composite (Built-in)
      library: kotlin-stdlib
      recommended: true
  swift:
    - name: Protocol Composite (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Abstract Composite (Built-in)
      library: dart-core
      recommended: true
    - name: Flutter Widget Tree
      library: flutter
common_patterns:
  - Tree traversal (depth-first, breadth-first)
  - Recursive operations
  - Parent-child relationships
  - Leaf and composite nodes
best_practices:
  do:
    - Make leaf and composite share same interface
    - Use recursive algorithms for tree operations
    - Consider iterator for traversal
    - Handle null children safely
    - Provide parent references if needed
  dont:
    - Add composite-specific methods to leaf
    - Create circular references
    - Forget null checks
    - Mix business logic with structure
related_functions:
  - None
tags: [composite, structural-pattern, tree, hierarchy, recursive]
updated: 2026-01-20
---

## TypeScript

### File System Example
```typescript
// Component interface
interface FileSystemComponent {
  getName(): string;
  getSize(): number;
  print(indent?: string): void;
}

// Leaf
class File implements FileSystemComponent {
  constructor(
    private name: string,
    private size: number
  ) {}

  getName(): string {
    return this.name;
  }

  getSize(): number {
    return this.size;
  }

  print(indent: string = ''): void {
    console.log(`${indent}📄 ${this.name} (${this.size} KB)`);
  }
}

// Composite
class Directory implements FileSystemComponent {
  private children: FileSystemComponent[] = [];

  constructor(private name: string) {}

  add(component: FileSystemComponent): void {
    this.children.push(component);
  }

  remove(component: FileSystemComponent): void {
    const index = this.children.indexOf(component);
    if (index !== -1) {
      this.children.splice(index, 1);
    }
  }

  getName(): string {
    return this.name;
  }

  getSize(): number {
    return this.children.reduce((total, child) => total + child.getSize(), 0);
  }

  print(indent: string = ''): void {
    console.log(`${indent}📁 ${this.name} (${this.getSize()} KB)`);
    for (const child of this.children) {
      child.print(indent + '  ');
    }
  }
}

// Usage
const root = new Directory('root');

const documents = new Directory('documents');
documents.add(new File('resume.pdf', 150));
documents.add(new File('cover-letter.docx', 50));

const photos = new Directory('photos');
photos.add(new File('vacation.jpg', 2000));
photos.add(new File('family.jpg', 1500));

root.add(documents);
root.add(photos);
root.add(new File('readme.txt', 5));

root.print();
console.log(`Total size: ${root.getSize()} KB`);
```

### UI Component Tree Example
```typescript
interface UIComponent {
  render(): string;
  getChildCount(): number;
}

class Button implements UIComponent {
  constructor(private text: string) {}

  render(): string {
    return `<button>${this.text}</button>`;
  }

  getChildCount(): number {
    return 0;
  }
}

class Input implements UIComponent {
  constructor(
    private type: string,
    private placeholder: string
  ) {}

  render(): string {
    return `<input type="${this.type}" placeholder="${this.placeholder}" />`;
  }

  getChildCount(): number {
    return 0;
  }
}

class Panel implements UIComponent {
  private children: UIComponent[] = [];

  constructor(private className: string) {}

  add(component: UIComponent): void {
    this.children.push(component);
  }

  render(): string {
    const childrenHtml = this.children.map(c => c.render()).join('\n  ');
    return `<div class="${this.className}">\n  ${childrenHtml}\n</div>`;
  }

  getChildCount(): number {
    return this.children.reduce(
      (total, child) => total + 1 + child.getChildCount(),
      0
    );
  }
}

// Usage
const form = new Panel('form-container');
form.add(new Input('text', 'Enter name'));
form.add(new Input('email', 'Enter email'));

const buttonGroup = new Panel('button-group');
buttonGroup.add(new Button('Submit'));
buttonGroup.add(new Button('Cancel'));

form.add(buttonGroup);

console.log(form.render());
console.log(`Total components: ${form.getChildCount()}`);
```

---

## Python

### File System Example
```python
from abc import ABC, abstractmethod
from typing import List

# Component interface
class FileSystemComponent(ABC):
    @abstractmethod
    def get_name(self) -> str:
        pass

    @abstractmethod
    def get_size(self) -> int:
        pass

    @abstractmethod
    def print(self, indent: str = "") -> None:
        pass

# Leaf
class File(FileSystemComponent):
    def __init__(self, name: str, size: int):
        self._name = name
        self._size = size

    def get_name(self) -> str:
        return self._name

    def get_size(self) -> int:
        return self._size

    def print(self, indent: str = "") -> None:
        print(f"{indent}📄 {self._name} ({self._size} KB)")

# Composite
class Directory(FileSystemComponent):
    def __init__(self, name: str):
        self._name = name
        self._children: List[FileSystemComponent] = []

    def add(self, component: FileSystemComponent) -> None:
        self._children.append(component)

    def remove(self, component: FileSystemComponent) -> None:
        self._children.remove(component)

    def get_name(self) -> str:
        return self._name

    def get_size(self) -> int:
        return sum(child.get_size() for child in self._children)

    def print(self, indent: str = "") -> None:
        print(f"{indent}📁 {self._name} ({self.get_size()} KB)")
        for child in self._children:
            child.print(indent + "  ")

# Usage
root = Directory("root")

documents = Directory("documents")
documents.add(File("resume.pdf", 150))
documents.add(File("cover-letter.docx", 50))

photos = Directory("photos")
photos.add(File("vacation.jpg", 2000))
photos.add(File("family.jpg", 1500))

root.add(documents)
root.add(photos)
root.add(File("readme.txt", 5))

root.print()
print(f"Total size: {root.get_size()} KB")
```

---

## Java

### File System Example
```java
import java.util.ArrayList;
import java.util.List;

// Component interface
interface FileSystemComponent {
    String getName();
    int getSize();
    void print(String indent);
}

// Leaf
class File implements FileSystemComponent {
    private final String name;
    private final int size;

    public File(String name, int size) {
        this.name = name;
        this.size = size;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public int getSize() {
        return size;
    }

    @Override
    public void print(String indent) {
        System.out.println(indent + "📄 " + name + " (" + size + " KB)");
    }
}

// Composite
class Directory implements FileSystemComponent {
    private final String name;
    private final List<FileSystemComponent> children = new ArrayList<>();

    public Directory(String name) {
        this.name = name;
    }

    public void add(FileSystemComponent component) {
        children.add(component);
    }

    public void remove(FileSystemComponent component) {
        children.remove(component);
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public int getSize() {
        return children.stream()
            .mapToInt(FileSystemComponent::getSize)
            .sum();
    }

    @Override
    public void print(String indent) {
        System.out.println(indent + "📁 " + name + " (" + getSize() + " KB)");
        for (FileSystemComponent child : children) {
            child.print(indent + "  ");
        }
    }
}

// Usage
Directory root = new Directory("root");

Directory documents = new Directory("documents");
documents.add(new File("resume.pdf", 150));
documents.add(new File("cover-letter.docx", 50));

Directory photos = new Directory("photos");
photos.add(new File("vacation.jpg", 2000));
photos.add(new File("family.jpg", 1500));

root.add(documents);
root.add(photos);
root.add(new File("readme.txt", 5));

root.print("");
System.out.println("Total size: " + root.getSize() + " KB");
```

---

## C#

### File System Example
```csharp
// Component interface
public interface IFileSystemComponent
{
    string GetName();
    int GetSize();
    void Print(string indent = "");
}

// Leaf
public class File : IFileSystemComponent
{
    private readonly string _name;
    private readonly int _size;

    public File(string name, int size)
    {
        _name = name;
        _size = size;
    }

    public string GetName() => _name;

    public int GetSize() => _size;

    public void Print(string indent = "")
    {
        Console.WriteLine($"{indent}📄 {_name} ({_size} KB)");
    }
}

// Composite
public class Directory : IFileSystemComponent
{
    private readonly string _name;
    private readonly List<IFileSystemComponent> _children = new();

    public Directory(string name)
    {
        _name = name;
    }

    public void Add(IFileSystemComponent component)
    {
        _children.Add(component);
    }

    public void Remove(IFileSystemComponent component)
    {
        _children.Remove(component);
    }

    public string GetName() => _name;

    public int GetSize()
    {
        return _children.Sum(child => child.GetSize());
    }

    public void Print(string indent = "")
    {
        Console.WriteLine($"{indent}📁 {_name} ({GetSize()} KB)");
        foreach (var child in _children)
        {
            child.Print(indent + "  ");
        }
    }
}

// Usage
var root = new Directory("root");

var documents = new Directory("documents");
documents.Add(new File("resume.pdf", 150));
documents.Add(new File("cover-letter.docx", 50));

var photos = new Directory("photos");
photos.Add(new File("vacation.jpg", 2000));
photos.Add(new File("family.jpg", 1500));

root.Add(documents);
root.Add(photos);
root.Add(new File("readme.txt", 5));

root.Print();
Console.WriteLine($"Total size: {root.GetSize()} KB");
```

---

## PHP

### File System Example
```php
// Component interface
interface FileSystemComponent
{
    public function getName(): string;
    public function getSize(): int;
    public function print(string $indent = ''): void;
}

// Leaf
class File implements FileSystemComponent
{
    public function __construct(
        private string $name,
        private int $size
    ) {}

    public function getName(): string
    {
        return $this->name;
    }

    public function getSize(): int
    {
        return $this->size;
    }

    public function print(string $indent = ''): void
    {
        echo "{$indent}📄 {$this->name} ({$this->size} KB)\n";
    }
}

// Composite
class Directory implements FileSystemComponent
{
    private array $children = [];

    public function __construct(private string $name) {}

    public function add(FileSystemComponent $component): void
    {
        $this->children[] = $component;
    }

    public function remove(FileSystemComponent $component): void
    {
        $key = array_search($component, $this->children, true);
        if ($key !== false) {
            unset($this->children[$key]);
        }
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getSize(): int
    {
        return array_reduce(
            $this->children,
            fn($total, $child) => $total + $child->getSize(),
            0
        );
    }

    public function print(string $indent = ''): void
    {
        echo "{$indent}📁 {$this->name} ({$this->getSize()} KB)\n";
        foreach ($this->children as $child) {
            $child->print($indent . '  ');
        }
    }
}

// Usage
$root = new Directory('root');

$documents = new Directory('documents');
$documents->add(new File('resume.pdf', 150));
$documents->add(new File('cover-letter.docx', 50));

$photos = new Directory('photos');
$photos->add(new File('vacation.jpg', 2000));
$photos->add(new File('family.jpg', 1500));

$root->add($documents);
$root->add($photos);
$root->add(new File('readme.txt', 5));

$root->print();
echo "Total size: {$root->getSize()} KB\n";
```

---

## Kotlin

### File System Example
```kotlin
// Component interface
interface FileSystemComponent {
    fun getName(): String
    fun getSize(): Int
    fun print(indent: String = "")
}

// Leaf
class File(
    private val name: String,
    private val size: Int
) : FileSystemComponent {
    override fun getName() = name
    override fun getSize() = size

    override fun print(indent: String) {
        println("$indent📄 $name ($size KB)")
    }
}

// Composite
class Directory(private val name: String) : FileSystemComponent {
    private val children = mutableListOf<FileSystemComponent>()

    fun add(component: FileSystemComponent) {
        children.add(component)
    }

    fun remove(component: FileSystemComponent) {
        children.remove(component)
    }

    override fun getName() = name

    override fun getSize(): Int {
        return children.sumOf { it.getSize() }
    }

    override fun print(indent: String) {
        println("$indent📁 $name (${getSize()} KB)")
        children.forEach { it.print("$indent  ") }
    }
}

// Usage
val root = Directory("root")

val documents = Directory("documents")
documents.add(File("resume.pdf", 150))
documents.add(File("cover-letter.docx", 50))

val photos = Directory("photos")
photos.add(File("vacation.jpg", 2000))
photos.add(File("family.jpg", 1500))

root.add(documents)
root.add(photos)
root.add(File("readme.txt", 5))

root.print()
println("Total size: ${root.getSize()} KB")
```

---

## Swift

### File System Example
```swift
// Component protocol
protocol FileSystemComponent {
    func getName() -> String
    func getSize() -> Int
    func print(indent: String)
}

// Leaf
class File: FileSystemComponent {
    private let name: String
    private let size: Int
    
    init(name: String, size: Int) {
        self.name = name
        self.size = size
    }
    
    func getName() -> String {
        return name
    }
    
    func getSize() -> Int {
        return size
    }
    
    func print(indent: String) {
        Swift.print("\(indent)📄 \(name) (\(size) KB)")
    }
}

// Composite
class Directory: FileSystemComponent {
    private let name: String
    private var children: [FileSystemComponent] = []
    
    init(name: String) {
        self.name = name
    }
    
    func add(_ component: FileSystemComponent) {
        children.append(component)
    }
    
    func remove(_ component: FileSystemComponent) {
        children.removeAll { $0 as AnyObject === component as AnyObject }
    }
    
    func getName() -> String {
        return name
    }
    
    func getSize() -> Int {
        return children.reduce(0) { $0 + $1.getSize() }
    }
    
    func print(indent: String) {
        Swift.print("\(indent)📁 \(name) (\(getSize()) KB)")
        for child in children {
            child.print(indent: indent + "  ")
        }
    }
}

// Usage
let root = Directory(name: "root")

let documents = Directory(name: "documents")
documents.add(File(name: "resume.pdf", size: 150))
documents.add(File(name: "cover-letter.docx", size: 50))

let photos = Directory(name: "photos")
photos.add(File(name: "vacation.jpg", size: 2000))
photos.add(File(name: "family.jpg", size: 1500))

root.add(documents)
root.add(photos)
root.add(File(name: "readme.txt", size: 5))

root.print(indent: "")
print("Total size: \(root.getSize()) KB")
```

---

## Dart

### File System Example
```dart
// Component interface
abstract class FileSystemComponent {
  String getName();
  int getSize();
  void print([String indent = '']);
}

// Leaf
class File implements FileSystemComponent {
  final String name;
  final int size;

  File(this.name, this.size);

  @override
  String getName() => name;

  @override
  int getSize() => size;

  @override
  void print([String indent = '']) {
    // ignore: avoid_print
    print('$indent📄 $name ($size KB)');
  }
}

// Composite
class Directory implements FileSystemComponent {
  final String name;
  final List<FileSystemComponent> _children = [];

  Directory(this.name);

  void add(FileSystemComponent component) {
    _children.add(component);
  }

  void remove(FileSystemComponent component) {
    _children.remove(component);
  }

  @override
  String getName() => name;

  @override
  int getSize() {
    return _children.fold(0, (total, child) => total + child.getSize());
  }

  @override
  void print([String indent = '']) {
    // ignore: avoid_print
    print('$indent📁 $name (${getSize()} KB)');
    for (final child in _children) {
      child.print('$indent  ');
    }
  }
}

// Usage
void main() {
  final root = Directory('root');

  final documents = Directory('documents');
  documents.add(File('resume.pdf', 150));
  documents.add(File('cover-letter.docx', 50));

  final photos = Directory('photos');
  photos.add(File('vacation.jpg', 2000));
  photos.add(File('family.jpg', 1500));

  root.add(documents);
  root.add(photos);
  root.add(File('readme.txt', 5));

  root.print();
  print('Total size: ${root.getSize()} KB');
}
```

### Flutter Widget Tree Example
```dart
import 'package:flutter/material.dart';

// Flutter's widget tree is a built-in composite pattern
class CompositeWidgetExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Column is a composite that contains multiple children
    return Column(
      children: [
        // Row is also a composite
        Row(
          children: [
            Text('Name:'),
            TextField(),
          ],
        ),
        Row(
          children: [
            Text('Email:'),
            TextField(),
          ],
        ),
        // Container is a leaf (single child)
        Container(
          child: ElevatedButton(
            onPressed: () {},
            child: Text('Submit'),
          ),
        ),
      ],
    );
  }
}
```

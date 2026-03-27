---
title: Command Pattern
category: Behavioral Design Pattern
difficulty: intermediate
purpose: Encapsulate a request as an object, allowing parameterization of clients with different requests, queuing, and undo operations
when_to_use:
  - Undo/redo functionality
  - Transaction systems
  - Task queues and job schedulers
  - Macro recording
  - GUI buttons and menu actions
  - Remote control systems
languages:
  typescript:
    - name: Class Command (Built-in)
      library: javascript-core
      recommended: true
    - name: Function Command (Built-in)
      library: javascript-core
  python:
    - name: Class Command (Built-in)
      library: python-core
      recommended: true
    - name: Callable Command (Built-in)
      library: python-core
  java:
    - name: Interface Command (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Interface Command (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Interface Command (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Interface Command (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Function Type Command (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Protocol Command (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Closure Command (Built-in)
      library: swift-stdlib
  dart:
    - name: Abstract Command (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Command with undo/redo
  - Macro commands (composite)
  - Command queue/history
  - Asynchronous command execution
  - Transaction management
best_practices:
  do:
    - Separate command creation from execution
    - Store necessary data in command object
    - Implement undo for reversible commands
    - Use command queue for async operations
    - Keep commands small and focused
  dont:
    - Put complex business logic in commands
    - Create commands without receivers
    - Forget to validate before execution
    - Make commands stateful unnecessarily
related_functions:
  - async-operations.md
tags: [command, behavioral-pattern, undo, queue, transaction]
updated: 2026-01-20
---

## TypeScript

### Command with Undo/Redo
```typescript
// Command interface
interface Command {
  execute(): void;
  undo(): void;
}

// Receiver
class TextEditor {
  private content: string = '';

  write(text: string): void {
    this.content += text;
  }

  deleteLastChars(count: number): void {
    this.content = this.content.slice(0, -count);
  }

  getContent(): string {
    return this.content;
  }
}

// Concrete commands
class WriteCommand implements Command {
  private backup: string = '';

  constructor(
    private editor: TextEditor,
    private text: string
  ) {}

  execute(): void {
    this.backup = this.editor.getContent();
    this.editor.write(this.text);
  }

  undo(): void {
    this.editor.deleteLastChars(this.text.length);
  }
}

class DeleteCommand implements Command {
  private backup: string = '';

  constructor(
    private editor: TextEditor,
    private count: number
  ) {}

  execute(): void {
    this.backup = this.editor.getContent();
    this.editor.deleteLastChars(this.count);
  }

  undo(): void {
    const deletedText = this.backup.slice(-this.count);
    this.editor.write(deletedText);
  }
}

// Invoker
class CommandHistory {
  private history: Command[] = [];
  private currentPosition: number = -1;

  execute(command: Command): void {
    // Remove all commands after current position (if we're in middle of history)
    this.history = this.history.slice(0, this.currentPosition + 1);
    
    command.execute();
    this.history.push(command);
    this.currentPosition++;
  }

  undo(): void {
    if (this.currentPosition >= 0) {
      const command = this.history[this.currentPosition];
      command.undo();
      this.currentPosition--;
    }
  }

  redo(): void {
    if (this.currentPosition < this.history.length - 1) {
      this.currentPosition++;
      const command = this.history[this.currentPosition];
      command.execute();
    }
  }
}

// Usage
const editor = new TextEditor();
const history = new CommandHistory();

history.execute(new WriteCommand(editor, 'Hello '));
history.execute(new WriteCommand(editor, 'World'));
console.log(editor.getContent()); // "Hello World"

history.undo();
console.log(editor.getContent()); // "Hello "

history.redo();
console.log(editor.getContent()); // "Hello World"
```

### Macro Command (Composite)
```typescript
class MacroCommand implements Command {
  private commands: Command[] = [];

  add(command: Command): void {
    this.commands.push(command);
  }

  execute(): void {
    for (const command of this.commands) {
      command.execute();
    }
  }

  undo(): void {
    // Undo in reverse order
    for (let i = this.commands.length - 1; i >= 0; i--) {
      this.commands[i].undo();
    }
  }
}

// Usage
const macro = new MacroCommand();
macro.add(new WriteCommand(editor, 'Hello'));
macro.add(new WriteCommand(editor, ' '));
macro.add(new WriteCommand(editor, 'World'));

history.execute(macro);
```

---

## Python

### Command with Undo/Redo
```python
from abc import ABC, abstractmethod
from typing import List

# Command interface
class Command(ABC):
    @abstractmethod
    def execute(self) -> None:
        pass

    @abstractmethod
    def undo(self) -> None:
        pass

# Receiver
class TextEditor:
    def __init__(self):
        self._content: str = ""

    def write(self, text: str) -> None:
        self._content += text

    def delete_last_chars(self, count: int) -> None:
        self._content = self._content[:-count]

    def get_content(self) -> str:
        return self._content

# Concrete commands
class WriteCommand(Command):
    def __init__(self, editor: TextEditor, text: str):
        self._editor = editor
        self._text = text
        self._backup: str = ""

    def execute(self) -> None:
        self._backup = self._editor.get_content()
        self._editor.write(self._text)

    def undo(self) -> None:
        self._editor.delete_last_chars(len(self._text))

class DeleteCommand(Command):
    def __init__(self, editor: TextEditor, count: int):
        self._editor = editor
        self._count = count
        self._backup: str = ""

    def execute(self) -> None:
        self._backup = self._editor.get_content()
        self._editor.delete_last_chars(self._count)

    def undo(self) -> None:
        deleted_text = self._backup[-self._count:]
        self._editor.write(deleted_text)

# Invoker
class CommandHistory:
    def __init__(self):
        self._history: List[Command] = []
        self._current_position: int = -1

    def execute(self, command: Command) -> None:
        # Remove all commands after current position
        self._history = self._history[:self._current_position + 1]
        
        command.execute()
        self._history.append(command)
        self._current_position += 1

    def undo(self) -> None:
        if self._current_position >= 0:
            command = self._history[self._current_position]
            command.undo()
            self._current_position -= 1

    def redo(self) -> None:
        if self._current_position < len(self._history) - 1:
            self._current_position += 1
            command = self._history[self._current_position]
            command.execute()

# Usage
editor = TextEditor()
history = CommandHistory()

history.execute(WriteCommand(editor, "Hello "))
history.execute(WriteCommand(editor, "World"))
print(editor.get_content())  # "Hello World"

history.undo()
print(editor.get_content())  # "Hello "

history.redo()
print(editor.get_content())  # "Hello World"
```

---

## Java

### Command with Undo/Redo
```java
// Command interface
interface Command {
    void execute();
    void undo();
}

// Receiver
class TextEditor {
    private String content = "";

    public void write(String text) {
        content += text;
    }

    public void deleteLastChars(int count) {
        if (count <= content.length()) {
            content = content.substring(0, content.length() - count);
        }
    }

    public String getContent() {
        return content;
    }
}

// Concrete commands
class WriteCommand implements Command {
    private final TextEditor editor;
    private final String text;
    private String backup = "";

    public WriteCommand(TextEditor editor, String text) {
        this.editor = editor;
        this.text = text;
    }

    @Override
    public void execute() {
        backup = editor.getContent();
        editor.write(text);
    }

    @Override
    public void undo() {
        editor.deleteLastChars(text.length());
    }
}

class DeleteCommand implements Command {
    private final TextEditor editor;
    private final int count;
    private String backup = "";

    public DeleteCommand(TextEditor editor, int count) {
        this.editor = editor;
        this.count = count;
    }

    @Override
    public void execute() {
        backup = editor.getContent();
        editor.deleteLastChars(count);
    }

    @Override
    public void undo() {
        String deletedText = backup.substring(backup.length() - count);
        editor.write(deletedText);
    }
}

// Invoker
class CommandHistory {
    private final List<Command> history = new ArrayList<>();
    private int currentPosition = -1;

    public void execute(Command command) {
        // Remove commands after current position
        if (currentPosition < history.size() - 1) {
            history.subList(currentPosition + 1, history.size()).clear();
        }
        
        command.execute();
        history.add(command);
        currentPosition++;
    }

    public void undo() {
        if (currentPosition >= 0) {
            Command command = history.get(currentPosition);
            command.undo();
            currentPosition--;
        }
    }

    public void redo() {
        if (currentPosition < history.size() - 1) {
            currentPosition++;
            Command command = history.get(currentPosition);
            command.execute();
        }
    }
}

// Usage
TextEditor editor = new TextEditor();
CommandHistory history = new CommandHistory();

history.execute(new WriteCommand(editor, "Hello "));
history.execute(new WriteCommand(editor, "World"));
System.out.println(editor.getContent()); // "Hello World"

history.undo();
System.out.println(editor.getContent()); // "Hello "

history.redo();
System.out.println(editor.getContent()); // "Hello World"
```

---

## C#

### Command with Undo/Redo
```csharp
// Command interface
public interface ICommand
{
    void Execute();
    void Undo();
}

// Receiver
public class TextEditor
{
    private string _content = "";

    public void Write(string text)
    {
        _content += text;
    }

    public void DeleteLastChars(int count)
    {
        if (count <= _content.Length)
        {
            _content = _content[..^count];
        }
    }

    public string GetContent() => _content;
}

// Concrete commands
public class WriteCommand : ICommand
{
    private readonly TextEditor _editor;
    private readonly string _text;
    private string _backup = "";

    public WriteCommand(TextEditor editor, string text)
    {
        _editor = editor;
        _text = text;
    }

    public void Execute()
    {
        _backup = _editor.GetContent();
        _editor.Write(_text);
    }

    public void Undo()
    {
        _editor.DeleteLastChars(_text.Length);
    }
}

public class DeleteCommand : ICommand
{
    private readonly TextEditor _editor;
    private readonly int _count;
    private string _backup = "";

    public DeleteCommand(TextEditor editor, int count)
    {
        _editor = editor;
        _count = count;
    }

    public void Execute()
    {
        _backup = _editor.GetContent();
        _editor.DeleteLastChars(_count);
    }

    public void Undo()
    {
        string deletedText = _backup[^_count..];
        _editor.Write(deletedText);
    }
}

// Invoker
public class CommandHistory
{
    private readonly List<ICommand> _history = new();
    private int _currentPosition = -1;

    public void Execute(ICommand command)
    {
        // Remove commands after current position
        if (_currentPosition < _history.Count - 1)
        {
            _history.RemoveRange(_currentPosition + 1, _history.Count - _currentPosition - 1);
        }
        
        command.Execute();
        _history.Add(command);
        _currentPosition++;
    }

    public void Undo()
    {
        if (_currentPosition >= 0)
        {
            var command = _history[_currentPosition];
            command.Undo();
            _currentPosition--;
        }
    }

    public void Redo()
    {
        if (_currentPosition < _history.Count - 1)
        {
            _currentPosition++;
            var command = _history[_currentPosition];
            command.Execute();
        }
    }
}

// Usage
var editor = new TextEditor();
var history = new CommandHistory();

history.Execute(new WriteCommand(editor, "Hello "));
history.Execute(new WriteCommand(editor, "World"));
Console.WriteLine(editor.GetContent()); // "Hello World"

history.Undo();
Console.WriteLine(editor.GetContent()); // "Hello "

history.Redo();
Console.WriteLine(editor.GetContent()); // "Hello World"
```

---

## PHP

### Command with Undo/Redo
```php
// Command interface
interface Command
{
    public function execute(): void;
    public function undo(): void;
}

// Receiver
class TextEditor
{
    private string $content = '';

    public function write(string $text): void
    {
        $this->content .= $text;
    }

    public function deleteLastChars(int $count): void
    {
        $this->content = substr($this->content, 0, -$count);
    }

    public function getContent(): string
    {
        return $this->content;
    }
}

// Concrete commands
class WriteCommand implements Command
{
    private string $backup = '';

    public function __construct(
        private TextEditor $editor,
        private string $text
    ) {}

    public function execute(): void
    {
        $this->backup = $this->editor->getContent();
        $this->editor->write($this->text);
    }

    public function undo(): void
    {
        $this->editor->deleteLastChars(strlen($this->text));
    }
}

class DeleteCommand implements Command
{
    private string $backup = '';

    public function __construct(
        private TextEditor $editor,
        private int $count
    ) {}

    public function execute(): void
    {
        $this->backup = $this->editor->getContent();
        $this->editor->deleteLastChars($this->count);
    }

    public function undo(): void
    {
        $deletedText = substr($this->backup, -$this->count);
        $this->editor->write($deletedText);
    }
}

// Invoker
class CommandHistory
{
    private array $history = [];
    private int $currentPosition = -1;

    public function execute(Command $command): void
    {
        // Remove commands after current position
        $this->history = array_slice($this->history, 0, $this->currentPosition + 1);
        
        $command->execute();
        $this->history[] = $command;
        $this->currentPosition++;
    }

    public function undo(): void
    {
        if ($this->currentPosition >= 0) {
            $command = $this->history[$this->currentPosition];
            $command->undo();
            $this->currentPosition--;
        }
    }

    public function redo(): void
    {
        if ($this->currentPosition < count($this->history) - 1) {
            $this->currentPosition++;
            $command = $this->history[$this->currentPosition];
            $command->execute();
        }
    }
}

// Usage
$editor = new TextEditor();
$history = new CommandHistory();

$history->execute(new WriteCommand($editor, 'Hello '));
$history->execute(new WriteCommand($editor, 'World'));
echo $editor->getContent() . "\n"; // "Hello World"

$history->undo();
echo $editor->getContent() . "\n"; // "Hello "

$history->redo();
echo $editor->getContent() . "\n"; // "Hello World"
```

---

## Kotlin

### Command with Undo/Redo
```kotlin
// Command interface
interface Command {
    fun execute()
    fun undo()
}

// Receiver
class TextEditor {
    private var content: String = ""

    fun write(text: String) {
        content += text
    }

    fun deleteLastChars(count: Int) {
        content = content.dropLast(count)
    }

    fun getContent(): String = content
}

// Concrete commands
class WriteCommand(
    private val editor: TextEditor,
    private val text: String
) : Command {
    private var backup: String = ""

    override fun execute() {
        backup = editor.getContent()
        editor.write(text)
    }

    override fun undo() {
        editor.deleteLastChars(text.length)
    }
}

class DeleteCommand(
    private val editor: TextEditor,
    private val count: Int
) : Command {
    private var backup: String = ""

    override fun execute() {
        backup = editor.getContent()
        editor.deleteLastChars(count)
    }

    override fun undo() {
        val deletedText = backup.takeLast(count)
        editor.write(deletedText)
    }
}

// Invoker
class CommandHistory {
    private val history = mutableListOf<Command>()
    private var currentPosition = -1

    fun execute(command: Command) {
        // Remove commands after current position
        if (currentPosition < history.size - 1) {
            history.subList(currentPosition + 1, history.size).clear()
        }
        
        command.execute()
        history.add(command)
        currentPosition++
    }

    fun undo() {
        if (currentPosition >= 0) {
            val command = history[currentPosition]
            command.undo()
            currentPosition--
        }
    }

    fun redo() {
        if (currentPosition < history.size - 1) {
            currentPosition++
            val command = history[currentPosition]
            command.execute()
        }
    }
}

// Usage
val editor = TextEditor()
val history = CommandHistory()

history.execute(WriteCommand(editor, "Hello "))
history.execute(WriteCommand(editor, "World"))
println(editor.getContent()) // "Hello World"

history.undo()
println(editor.getContent()) // "Hello "

history.redo()
println(editor.getContent()) // "Hello World"
```

---

## Swift

### Command with Undo/Redo
```swift
// Command protocol
protocol Command {
    func execute()
    func undo()
}

// Receiver
class TextEditor {
    private var content: String = ""
    
    func write(_ text: String) {
        content += text
    }
    
    func deleteLastChars(_ count: Int) {
        if count <= content.count {
            content = String(content.dropLast(count))
        }
    }
    
    func getContent() -> String {
        return content
    }
}

// Concrete commands
class WriteCommand: Command {
    private let editor: TextEditor
    private let text: String
    private var backup: String = ""
    
    init(editor: TextEditor, text: String) {
        self.editor = editor
        self.text = text
    }
    
    func execute() {
        backup = editor.getContent()
        editor.write(text)
    }
    
    func undo() {
        editor.deleteLastChars(text.count)
    }
}

class DeleteCommand: Command {
    private let editor: TextEditor
    private let count: Int
    private var backup: String = ""
    
    init(editor: TextEditor, count: Int) {
        self.editor = editor
        self.count = count
    }
    
    func execute() {
        backup = editor.getContent()
        editor.deleteLastChars(count)
    }
    
    func undo() {
        let deletedText = String(backup.suffix(count))
        editor.write(deletedText)
    }
}

// Invoker
class CommandHistory {
    private var history: [Command] = []
    private var currentPosition: Int = -1
    
    func execute(_ command: Command) {
        // Remove commands after current position
        if currentPosition < history.count - 1 {
            history.removeLast(history.count - currentPosition - 1)
        }
        
        command.execute()
        history.append(command)
        currentPosition += 1
    }
    
    func undo() {
        if currentPosition >= 0 {
            let command = history[currentPosition]
            command.undo()
            currentPosition -= 1
        }
    }
    
    func redo() {
        if currentPosition < history.count - 1 {
            currentPosition += 1
            let command = history[currentPosition]
            command.execute()
        }
    }
}

// Usage
let editor = TextEditor()
let history = CommandHistory()

history.execute(WriteCommand(editor: editor, text: "Hello "))
history.execute(WriteCommand(editor: editor, text: "World"))
print(editor.getContent()) // "Hello World"

history.undo()
print(editor.getContent()) // "Hello "

history.redo()
print(editor.getContent()) // "Hello World"
```

---

## Dart

### Command with Undo/Redo
```dart
// Command interface
abstract class Command {
  void execute();
  void undo();
}

// Receiver
class TextEditor {
  String _content = '';

  void write(String text) {
    _content += text;
  }

  void deleteLastChars(int count) {
    if (count <= _content.length) {
      _content = _content.substring(0, _content.length - count);
    }
  }

  String getContent() => _content;
}

// Concrete commands
class WriteCommand implements Command {
  final TextEditor editor;
  final String text;
  String _backup = '';

  WriteCommand(this.editor, this.text);

  @override
  void execute() {
    _backup = editor.getContent();
    editor.write(text);
  }

  @override
  void undo() {
    editor.deleteLastChars(text.length);
  }
}

class DeleteCommand implements Command {
  final TextEditor editor;
  final int count;
  String _backup = '';

  DeleteCommand(this.editor, this.count);

  @override
  void execute() {
    _backup = editor.getContent();
    editor.deleteLastChars(count);
  }

  @override
  void undo() {
    final deletedText = _backup.substring(_backup.length - count);
    editor.write(deletedText);
  }
}

// Invoker
class CommandHistory {
  final List<Command> _history = [];
  int _currentPosition = -1;

  void execute(Command command) {
    // Remove commands after current position
    if (_currentPosition < _history.length - 1) {
      _history.removeRange(_currentPosition + 1, _history.length);
    }
    
    command.execute();
    _history.add(command);
    _currentPosition++;
  }

  void undo() {
    if (_currentPosition >= 0) {
      final command = _history[_currentPosition];
      command.undo();
      _currentPosition--;
    }
  }

  void redo() {
    if (_currentPosition < _history.length - 1) {
      _currentPosition++;
      final command = _history[_currentPosition];
      command.execute();
    }
  }
}

// Usage
final editor = TextEditor();
final history = CommandHistory();

history.execute(WriteCommand(editor, 'Hello '));
history.execute(WriteCommand(editor, 'World'));
print(editor.getContent()); // "Hello World"

history.undo();
print(editor.getContent()); // "Hello "

history.redo();
print(editor.getContent()); // "Hello World"
```

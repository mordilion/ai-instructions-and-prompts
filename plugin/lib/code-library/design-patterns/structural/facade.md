---
title: Facade Pattern
category: Structural Design Pattern
difficulty: beginner
purpose: Provide a simplified interface to a complex subsystem, library, or framework
when_to_use:
  - Simplifying complex library APIs
  - Creating unified interfaces for multiple systems
  - Isolating application from subsystem complexity
  - Providing convenience methods for common operations
  - Creating SDK/API wrappers
  - Microservice orchestration
languages:
  typescript:
    - name: Class Facade (Built-in)
      library: javascript-core
      recommended: true
  python:
    - name: Class Facade (Built-in)
      library: python-core
      recommended: true
  java:
    - name: Class Facade (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Class Facade (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Class Facade (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Class Facade (Built-in)
      library: kotlin-stdlib
      recommended: true
  swift:
    - name: Class Facade (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Class Facade (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Single entry point for complex subsystems
  - Aggregating multiple API calls
  - Providing default configurations
  - Hiding implementation complexity
best_practices:
  do:
    - Keep facade methods simple and focused
    - Provide sensible defaults
    - Handle common use cases
    - Document when to use facade vs direct subsystem access
    - Make facade optional (allow advanced users to bypass it)
  dont:
    - Add business logic to facade
    - Make facade a god object
    - Force all access through facade
    - Hide necessary complexity
related_functions:
  - http-requests.md
  - database-query.md
tags: [facade, structural-pattern, simplification, wrapper, unified-interface]
updated: 2026-01-20
---

## TypeScript

### Class Facade
```typescript
// Complex subsystem classes
class VideoConverter {
  convert(filename: string, format: string): string {
    console.log(`Converting ${filename} to ${format}...`);
    return `${filename}.${format}`;
  }
}

class AudioExtractor {
  extract(filename: string): string {
    console.log(`Extracting audio from ${filename}...`);
    return `${filename}.audio`;
  }
}

class CompressionCodec {
  compress(filename: string, quality: number): string {
    console.log(`Compressing ${filename} with quality ${quality}...`);
    return `${filename}.compressed`;
  }
}

class BitrateReader {
  read(filename: string): number {
    console.log(`Reading bitrate of ${filename}...`);
    return 1920;
  }

  convert(bitrate: number, format: string): number {
    console.log(`Converting bitrate ${bitrate} to ${format}...`);
    return bitrate * 0.8;
  }
}

// Facade providing simple interface
class VideoConversionFacade {
  private converter: VideoConverter;
  private audioExtractor: AudioExtractor;
  private codec: CompressionCodec;
  private bitrateReader: BitrateReader;

  constructor() {
    this.converter = new VideoConverter();
    this.audioExtractor = new AudioExtractor();
    this.codec = new CompressionCodec();
    this.bitrateReader = new BitrateReader();
  }

  convertVideo(filename: string, format: string): string {
    console.log('VideoConversionFacade: starting conversion...');
    
    // Step 1: Extract audio
    const audioFile = this.audioExtractor.extract(filename);
    
    // Step 2: Read and adjust bitrate
    const bitrate = this.bitrateReader.read(filename);
    const adjustedBitrate = this.bitrateReader.convert(bitrate, format);
    
    // Step 3: Compress
    const compressedFile = this.codec.compress(filename, adjustedBitrate);
    
    // Step 4: Convert
    const result = this.converter.convert(compressedFile, format);
    
    console.log('VideoConversionFacade: conversion complete');
    return result;
  }
}

// Usage - simple interface hides complexity
const facade = new VideoConversionFacade();
const result = facade.convertVideo('video.ogg', 'mp4');
```

### API Facade Example
```typescript
// Complex subsystems
class AuthService {
  authenticate(username: string, password: string): string {
    return 'auth-token-123';
  }
}

class UserService {
  getUserProfile(token: string): { id: string; name: string } {
    return { id: '1', name: 'John Doe' };
  }
}

class PermissionsService {
  getUserPermissions(userId: string): string[] {
    return ['read', 'write'];
  }
}

class AnalyticsService {
  trackLogin(userId: string): void {
    console.log(`Tracked login for user ${userId}`);
  }
}

// Facade simplifying the login flow
class AuthenticationFacade {
  private auth: AuthService;
  private users: UserService;
  private permissions: PermissionsService;
  private analytics: AnalyticsService;

  constructor() {
    this.auth = new AuthService();
    this.users = new UserService();
    this.permissions = new PermissionsService();
    this.analytics = new AnalyticsService();
  }

  async login(username: string, password: string) {
    // Orchestrate multiple services
    const token = this.auth.authenticate(username, password);
    const profile = this.users.getUserProfile(token);
    const permissions = this.permissions.getUserPermissions(profile.id);
    this.analytics.trackLogin(profile.id);

    return {
      token,
      user: profile,
      permissions,
    };
  }
}

// Usage
const authFacade = new AuthenticationFacade();
const session = await authFacade.login('john@example.com', 'password123');
```

---

## Python

### Class Facade
```python
# Complex subsystem classes
class VideoConverter:
    def convert(self, filename: str, format: str) -> str:
        print(f"Converting {filename} to {format}...")
        return f"{filename}.{format}"

class AudioExtractor:
    def extract(self, filename: str) -> str:
        print(f"Extracting audio from {filename}...")
        return f"{filename}.audio"

class CompressionCodec:
    def compress(self, filename: str, quality: int) -> str:
        print(f"Compressing {filename} with quality {quality}...")
        return f"{filename}.compressed"

class BitrateReader:
    def read(self, filename: str) -> int:
        print(f"Reading bitrate of {filename}...")
        return 1920

    def convert(self, bitrate: int, format: str) -> int:
        print(f"Converting bitrate {bitrate} to {format}...")
        return int(bitrate * 0.8)

# Facade
class VideoConversionFacade:
    def __init__(self):
        self._converter = VideoConverter()
        self._audio_extractor = AudioExtractor()
        self._codec = CompressionCodec()
        self._bitrate_reader = BitrateReader()

    def convert_video(self, filename: str, format: str) -> str:
        print("VideoConversionFacade: starting conversion...")
        
        # Orchestrate subsystems
        audio_file = self._audio_extractor.extract(filename)
        bitrate = self._bitrate_reader.read(filename)
        adjusted_bitrate = self._bitrate_reader.convert(bitrate, format)
        compressed_file = self._codec.compress(filename, adjusted_bitrate)
        result = self._converter.convert(compressed_file, format)
        
        print("VideoConversionFacade: conversion complete")
        return result

# Usage
facade = VideoConversionFacade()
result = facade.convert_video("video.ogg", "mp4")
```

---

## Java

### Class Facade
```java
// Complex subsystem classes
class VideoConverter {
    public String convert(String filename, String format) {
        System.out.println("Converting " + filename + " to " + format + "...");
        return filename + "." + format;
    }
}

class AudioExtractor {
    public String extract(String filename) {
        System.out.println("Extracting audio from " + filename + "...");
        return filename + ".audio";
    }
}

class CompressionCodec {
    public String compress(String filename, int quality) {
        System.out.println("Compressing " + filename + " with quality " + quality + "...");
        return filename + ".compressed";
    }
}

class BitrateReader {
    public int read(String filename) {
        System.out.println("Reading bitrate of " + filename + "...");
        return 1920;
    }

    public int convert(int bitrate, String format) {
        System.out.println("Converting bitrate " + bitrate + " to " + format + "...");
        return (int) (bitrate * 0.8);
    }
}

// Facade
public class VideoConversionFacade {
    private final VideoConverter converter;
    private final AudioExtractor audioExtractor;
    private final CompressionCodec codec;
    private final BitrateReader bitrateReader;

    public VideoConversionFacade() {
        this.converter = new VideoConverter();
        this.audioExtractor = new AudioExtractor();
        this.codec = new CompressionCodec();
        this.bitrateReader = new BitrateReader();
    }

    public String convertVideo(String filename, String format) {
        System.out.println("VideoConversionFacade: starting conversion...");
        
        String audioFile = audioExtractor.extract(filename);
        int bitrate = bitrateReader.read(filename);
        int adjustedBitrate = bitrateReader.convert(bitrate, format);
        String compressedFile = codec.compress(filename, adjustedBitrate);
        String result = converter.convert(compressedFile, format);
        
        System.out.println("VideoConversionFacade: conversion complete");
        return result;
    }
}

// Usage
VideoConversionFacade facade = new VideoConversionFacade();
String result = facade.convertVideo("video.ogg", "mp4");
```

---

## C#

### Class Facade
```csharp
// Complex subsystem classes
public class VideoConverter
{
    public string Convert(string filename, string format)
    {
        Console.WriteLine($"Converting {filename} to {format}...");
        return $"{filename}.{format}";
    }
}

public class AudioExtractor
{
    public string Extract(string filename)
    {
        Console.WriteLine($"Extracting audio from {filename}...");
        return $"{filename}.audio";
    }
}

public class CompressionCodec
{
    public string Compress(string filename, int quality)
    {
        Console.WriteLine($"Compressing {filename} with quality {quality}...");
        return $"{filename}.compressed";
    }
}

public class BitrateReader
{
    public int Read(string filename)
    {
        Console.WriteLine($"Reading bitrate of {filename}...");
        return 1920;
    }

    public int Convert(int bitrate, string format)
    {
        Console.WriteLine($"Converting bitrate {bitrate} to {format}...");
        return (int)(bitrate * 0.8);
    }
}

// Facade
public class VideoConversionFacade
{
    private readonly VideoConverter _converter;
    private readonly AudioExtractor _audioExtractor;
    private readonly CompressionCodec _codec;
    private readonly BitrateReader _bitrateReader;

    public VideoConversionFacade()
    {
        _converter = new VideoConverter();
        _audioExtractor = new AudioExtractor();
        _codec = new CompressionCodec();
        _bitrateReader = new BitrateReader();
    }

    public string ConvertVideo(string filename, string format)
    {
        Console.WriteLine("VideoConversionFacade: starting conversion...");
        
        var audioFile = _audioExtractor.Extract(filename);
        var bitrate = _bitrateReader.Read(filename);
        var adjustedBitrate = _bitrateReader.Convert(bitrate, format);
        var compressedFile = _codec.Compress(filename, adjustedBitrate);
        var result = _converter.Convert(compressedFile, format);
        
        Console.WriteLine("VideoConversionFacade: conversion complete");
        return result;
    }
}

// Usage
var facade = new VideoConversionFacade();
var result = facade.ConvertVideo("video.ogg", "mp4");
```

---

## PHP

### Class Facade
```php
// Complex subsystem classes
class VideoConverter
{
    public function convert(string $filename, string $format): string
    {
        echo "Converting $filename to $format...\n";
        return "$filename.$format";
    }
}

class AudioExtractor
{
    public function extract(string $filename): string
    {
        echo "Extracting audio from $filename...\n";
        return "$filename.audio";
    }
}

class CompressionCodec
{
    public function compress(string $filename, int $quality): string
    {
        echo "Compressing $filename with quality $quality...\n";
        return "$filename.compressed";
    }
}

class BitrateReader
{
    public function read(string $filename): int
    {
        echo "Reading bitrate of $filename...\n";
        return 1920;
    }

    public function convert(int $bitrate, string $format): int
    {
        echo "Converting bitrate $bitrate to $format...\n";
        return (int) ($bitrate * 0.8);
    }
}

// Facade
class VideoConversionFacade
{
    private VideoConverter $converter;
    private AudioExtractor $audioExtractor;
    private CompressionCodec $codec;
    private BitrateReader $bitrateReader;

    public function __construct()
    {
        $this->converter = new VideoConverter();
        $this->audioExtractor = new AudioExtractor();
        $this->codec = new CompressionCodec();
        $this->bitrateReader = new BitrateReader();
    }

    public function convertVideo(string $filename, string $format): string
    {
        echo "VideoConversionFacade: starting conversion...\n";
        
        $audioFile = $this->audioExtractor->extract($filename);
        $bitrate = $this->bitrateReader->read($filename);
        $adjustedBitrate = $this->bitrateReader->convert($bitrate, $format);
        $compressedFile = $this->codec->compress($filename, $adjustedBitrate);
        $result = $this->converter->convert($compressedFile, $format);
        
        echo "VideoConversionFacade: conversion complete\n";
        return $result;
    }
}

// Usage
$facade = new VideoConversionFacade();
$result = $facade->convertVideo('video.ogg', 'mp4');
```

---

## Kotlin

### Class Facade
```kotlin
// Complex subsystem classes
class VideoConverter {
    fun convert(filename: String, format: String): String {
        println("Converting $filename to $format...")
        return "$filename.$format"
    }
}

class AudioExtractor {
    fun extract(filename: String): String {
        println("Extracting audio from $filename...")
        return "$filename.audio"
    }
}

class CompressionCodec {
    fun compress(filename: String, quality: Int): String {
        println("Compressing $filename with quality $quality...")
        return "$filename.compressed"
    }
}

class BitrateReader {
    fun read(filename: String): Int {
        println("Reading bitrate of $filename...")
        return 1920
    }

    fun convert(bitrate: Int, format: String): Int {
        println("Converting bitrate $bitrate to $format...")
        return (bitrate * 0.8).toInt()
    }
}

// Facade
class VideoConversionFacade {
    private val converter = VideoConverter()
    private val audioExtractor = AudioExtractor()
    private val codec = CompressionCodec()
    private val bitrateReader = BitrateReader()

    fun convertVideo(filename: String, format: String): String {
        println("VideoConversionFacade: starting conversion...")
        
        val audioFile = audioExtractor.extract(filename)
        val bitrate = bitrateReader.read(filename)
        val adjustedBitrate = bitrateReader.convert(bitrate, format)
        val compressedFile = codec.compress(filename, adjustedBitrate)
        val result = converter.convert(compressedFile, format)
        
        println("VideoConversionFacade: conversion complete")
        return result
    }
}

// Usage
val facade = VideoConversionFacade()
val result = facade.convertVideo("video.ogg", "mp4")
```

---

## Swift

### Class Facade
```swift
// Complex subsystem classes
class VideoConverter {
    func convert(filename: String, format: String) -> String {
        print("Converting \(filename) to \(format)...")
        return "\(filename).\(format)"
    }
}

class AudioExtractor {
    func extract(filename: String) -> String {
        print("Extracting audio from \(filename)...")
        return "\(filename).audio"
    }
}

class CompressionCodec {
    func compress(filename: String, quality: Int) -> String {
        print("Compressing \(filename) with quality \(quality)...")
        return "\(filename).compressed"
    }
}

class BitrateReader {
    func read(filename: String) -> Int {
        print("Reading bitrate of \(filename)...")
        return 1920
    }
    
    func convert(bitrate: Int, format: String) -> Int {
        print("Converting bitrate \(bitrate) to \(format)...")
        return Int(Double(bitrate) * 0.8)
    }
}

// Facade
class VideoConversionFacade {
    private let converter = VideoConverter()
    private let audioExtractor = AudioExtractor()
    private let codec = CompressionCodec()
    private let bitrateReader = BitrateReader()
    
    func convertVideo(filename: String, format: String) -> String {
        print("VideoConversionFacade: starting conversion...")
        
        let audioFile = audioExtractor.extract(filename: filename)
        let bitrate = bitrateReader.read(filename: filename)
        let adjustedBitrate = bitrateReader.convert(bitrate: bitrate, format: format)
        let compressedFile = codec.compress(filename: filename, quality: adjustedBitrate)
        let result = converter.convert(filename: compressedFile, format: format)
        
        print("VideoConversionFacade: conversion complete")
        return result
    }
}

// Usage
let facade = VideoConversionFacade()
let result = facade.convertVideo(filename: "video.ogg", format: "mp4")
```

---

## Dart

### Class Facade
```dart
// Complex subsystem classes
class VideoConverter {
  String convert(String filename, String format) {
    print('Converting $filename to $format...');
    return '$filename.$format';
  }
}

class AudioExtractor {
  String extract(String filename) {
    print('Extracting audio from $filename...');
    return '$filename.audio';
  }
}

class CompressionCodec {
  String compress(String filename, int quality) {
    print('Compressing $filename with quality $quality...');
    return '$filename.compressed';
  }
}

class BitrateReader {
  int read(String filename) {
    print('Reading bitrate of $filename...');
    return 1920;
  }

  int convert(int bitrate, String format) {
    print('Converting bitrate $bitrate to $format...');
    return (bitrate * 0.8).toInt();
  }
}

// Facade
class VideoConversionFacade {
  final _converter = VideoConverter();
  final _audioExtractor = AudioExtractor();
  final _codec = CompressionCodec();
  final _bitrateReader = BitrateReader();

  String convertVideo(String filename, String format) {
    print('VideoConversionFacade: starting conversion...');
    
    final audioFile = _audioExtractor.extract(filename);
    final bitrate = _bitrateReader.read(filename);
    final adjustedBitrate = _bitrateReader.convert(bitrate, format);
    final compressedFile = _codec.compress(filename, adjustedBitrate);
    final result = _converter.convert(compressedFile, format);
    
    print('VideoConversionFacade: conversion complete');
    return result;
  }
}

// Usage
final facade = VideoConversionFacade();
final result = facade.convertVideo('video.ogg', 'mp4');
```

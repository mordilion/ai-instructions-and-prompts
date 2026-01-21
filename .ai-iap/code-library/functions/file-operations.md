---
title: File Operations Patterns
category: File Management
difficulty: intermediate
purpose: Secure file upload, download, streaming, and deletion with validation
when_to_use:
  - Uploading user files (avatars, documents, images)
  - Downloading files from server
  - Streaming large files to avoid memory issues
  - Safely deleting files with validation
languages:
  typescript:
    - name: Multer (Express)
      library: multer
      recommended: true
    - name: Formidable
      library: formidable
    - name: NestJS FileInterceptor
      library: "@nestjs/platform-express"
  python:
    - name: FastAPI UploadFile
      library: fastapi
      recommended: true
    - name: Django FileField
      library: django
    - name: Flask FileStorage
      library: flask
  java:
    - name: Spring MultipartFile
      library: spring-boot
      recommended: true
    - name: Apache Commons FileUpload
      library: commons-fileupload
  csharp:
    - name: IFormFile (ASP.NET Core)
      library: Microsoft.AspNetCore.Http
      recommended: true
    - name: Stream-based
      library: System.IO
  php:
    - name: Laravel Storage
      library: laravel/framework
      recommended: true
    - name: Symfony UploadedFile
      library: symfony/http-foundation
    - name: Native $_FILES
      library: php-core
  kotlin:
    - name: Ktor Content.MultiPart
      library: ktor
      recommended: true
    - name: Spring MultipartFile
      library: spring-boot
  swift:
    - name: Vapor FileIO
      library: vapor
      recommended: true
    - name: FileManager (Native)
      library: Foundation
  dart:
    - name: MultipartFile (http)
      library: http
      recommended: true
    - name: Shelf FileUpload
      library: shelf
common_patterns:
  - Validate file type and size before processing
  - Generate unique filenames to avoid conflicts
  - Store files outside web root for security
  - Stream large files to avoid memory exhaustion
  - Clean up temporary files after processing
best_practices:
  do:
    - Validate file extensions AND MIME types (both!)
    - Limit file sizes (prevent DoS)
    - Generate unique filenames (UUIDs)
    - Store files outside public directory
    - Scan for malware if handling user uploads
    - Use streaming for large files (>10MB)
    - Sanitize filenames (remove path traversal)
    - Set proper file permissions
  dont:
    - Trust client-supplied filenames
    - Store files with original filenames
    - Allow executable file uploads
    - Store files in web root
    - Load entire file into memory
    - Use user input directly in file paths
    - Skip MIME type validation
related_functions:
  - input-validation.md
  - error-handling.md
tags: [file-upload, file-download, streaming, security, file-management]
updated: 2026-01-20
---

## TypeScript

### Multer (Express) - File Upload (Recommended)

```typescript
import multer from 'multer';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|pdf/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  }
});

app.post('/upload', upload.single('file'), (req, res) => {
  res.json({ filename: req.file.filename });
});
```

### NestJS FileInterceptor

```typescript
import { Controller, Post, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';

@Controller('files')
export class FileController {
  @Post('upload')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueName = `${Date.now()}-${file.originalname}`;
        cb(null, uniqueName);
      }
    }),
    limits: { fileSize: 5 * 1024 * 1024 }
  }))
  uploadFile(@UploadedFile() file: Express.Multer.File) {
    return { filename: file.filename, size: file.size };
  }
}
```

### File Download & Streaming

```typescript
import { createReadStream } from 'fs';
import { stat } from 'fs/promises';

app.get('/download/:filename', async (req, res) => {
  const filename = path.basename(req.params.filename); // Sanitize
  const filepath = path.join('./uploads', filename);
  
  try {
    const stats = await stat(filepath);
    res.setHeader('Content-Length', stats.size);
    res.setHeader('Content-Type', 'application/octet-stream');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    
    const stream = createReadStream(filepath);
    stream.pipe(res);
  } catch (error) {
    res.status(404).json({ error: 'File not found' });
  }
});
```

---

## Python

### FastAPI UploadFile (Recommended)

```python
from fastapi import FastAPI, UploadFile, File, HTTPException
from pathlib import Path
import uuid
import shutil

app = FastAPI()

UPLOAD_DIR = Path("./uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

ALLOWED_TYPES = {"image/jpeg", "image/png", "application/pdf"}
MAX_SIZE = 5 * 1024 * 1024  # 5MB

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(400, "Invalid file type")
    
    contents = await file.read()
    if len(contents) > MAX_SIZE:
        raise HTTPException(400, "File too large")
    
    unique_name = f"{uuid.uuid4()}{Path(file.filename).suffix}"
    file_path = UPLOAD_DIR / unique_name
    
    with open(file_path, "wb") as f:
        f.write(contents)
    
    return {"filename": unique_name}
```

### FastAPI File Download & Streaming

```python
from fastapi.responses import FileResponse, StreamingResponse

@app.get("/download/{filename}")
async def download_file(filename: str):
    file_path = UPLOAD_DIR / filename
    
    if not file_path.exists():
        raise HTTPException(404, "File not found")
    
    return FileResponse(
        file_path,
        media_type="application/octet-stream",
        filename=filename
    )

@app.get("/stream/{filename}")
async def stream_file(filename: str):
    file_path = UPLOAD_DIR / filename
    
    if not file_path.exists():
        raise HTTPException(404, "File not found")
    
    def iterfile():
        with open(file_path, "rb") as f:
            yield from f
    
    return StreamingResponse(iterfile(), media_type="application/octet-stream")
```

### Django FileField

```python
from django.core.files.storage import FileSystemStorage
from django.http import FileResponse, Http404
import uuid

fs = FileSystemStorage(location='uploads/')

def upload_file(request):
    if request.method == 'POST' and request.FILES.get('file'):
        uploaded_file = request.FILES['file']
        
        # Validate
        if uploaded_file.size > 5 * 1024 * 1024:
            return JsonResponse({'error': 'File too large'}, status=400)
        
        unique_name = f"{uuid.uuid4()}_{uploaded_file.name}"
        filename = fs.save(unique_name, uploaded_file)
        
        return JsonResponse({'filename': filename})
```

---

## Java

### Spring MultipartFile (Recommended)

```java
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.*;
import java.nio.file.*;
import java.util.UUID;

@RestController
@RequestMapping("/files")
public class FileController {
    
    private final Path uploadDir = Paths.get("uploads");
    private static final long MAX_SIZE = 5 * 1024 * 1024; // 5MB
    
    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadFile(
            @RequestParam("file") MultipartFile file) {
        
        if (file.isEmpty()) {
            throw new BadRequestException("File is empty");
        }
        
        if (file.getSize() > MAX_SIZE) {
            throw new BadRequestException("File too large");
        }
        
        String contentType = file.getContentType();
        if (!isAllowedType(contentType)) {
            throw new BadRequestException("Invalid file type");
        }
        
        try {
            String uniqueName = UUID.randomUUID() + "-" + file.getOriginalFilename();
            Path filePath = uploadDir.resolve(uniqueName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            return ResponseEntity.ok(Map.of("filename", uniqueName));
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file", e);
        }
    }
    
    private boolean isAllowedType(String contentType) {
        return contentType != null && 
               (contentType.equals("image/jpeg") || 
                contentType.equals("image/png") || 
                contentType.equals("application/pdf"));
    }
}
```

### Spring File Download & Streaming

```java
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;

@GetMapping("/download/{filename}")
public ResponseEntity<Resource> downloadFile(@PathVariable String filename) {
    try {
        Path filePath = uploadDir.resolve(filename).normalize();
        Resource resource = new UrlResource(filePath.toUri());
        
        if (!resource.exists()) {
            throw new FileNotFoundException("File not found: " + filename);
        }
        
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, 
                       "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    } catch (MalformedURLException e) {
        throw new RuntimeException("Error: " + e.getMessage());
    }
}
```

---

## C#

### IFormFile (ASP.NET Core) - Recommended

```csharp
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.IO;

[ApiController]
[Route("api/files")]
public class FileController : ControllerBase
{
    private readonly string _uploadPath = "uploads";
    private const long MaxFileSize = 5 * 1024 * 1024; // 5MB
    
    [HttpPost("upload")]
    public async Task<ActionResult<FileUploadResult>> UploadFile(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded");
        
        if (file.Length > MaxFileSize)
            return BadRequest("File too large");
        
        var allowedTypes = new[] { "image/jpeg", "image/png", "application/pdf" };
        if (!allowedTypes.Contains(file.ContentType))
            return BadRequest("Invalid file type");
        
        var uniqueName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(_uploadPath, uniqueName);
        
        Directory.CreateDirectory(_uploadPath);
        
        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }
        
        return Ok(new { Filename = uniqueName });
    }
}
```

### File Download & Streaming

```csharp
[HttpGet("download/{filename}")]
public IActionResult DownloadFile(string filename)
{
    var filePath = Path.Combine(_uploadPath, filename);
    
    if (!System.IO.File.Exists(filePath))
        return NotFound();
    
    var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
    return File(stream, "application/octet-stream", filename);
}

[HttpGet("stream/{filename}")]
public async Task StreamFile(string filename)
{
    var filePath = Path.Combine(_uploadPath, filename);
    
    if (!System.IO.File.Exists(filePath))
    {
        Response.StatusCode = 404;
        return;
    }
    
    Response.ContentType = "application/octet-stream";
    await Response.SendFileAsync(filePath);
}
```

---

## PHP

### Laravel Storage (Recommended)

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class FileController extends Controller
{
    public function upload(Request $request)
    {
        $request->validate([
            'file' => 'required|file|max:5120|mimes:jpeg,png,pdf',
        ]);
        
        $file = $request->file('file');
        $uniqueName = Str::uuid() . '.' . $file->getClientOriginalExtension();
        
        $path = $file->storeAs('uploads', $uniqueName);
        
        return response()->json(['filename' => $uniqueName]);
    }
    
    public function download(string $filename)
    {
        if (!Storage::exists("uploads/{$filename}")) {
            abort(404);
        }
        
        return Storage::download("uploads/{$filename}");
    }
    
    public function stream(string $filename)
    {
        if (!Storage::exists("uploads/{$filename}")) {
            abort(404);
        }
        
        return response()->stream(function () use ($filename) {
            $stream = Storage::readStream("uploads/{$filename}");
            fpassthru($stream);
            fclose($stream);
        }, 200, [
            'Content-Type' => Storage::mimeType("uploads/{$filename}"),
        ]);
    }
}
```

### Symfony UploadedFile

```php
<?php

use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\HttpFoundation\Request;

class FileController
{
    public function upload(Request $request): JsonResponse
    {
        /** @var UploadedFile $file */
        $file = $request->files->get('file');
        
        if (!$file || !$file->isValid()) {
            return new JsonResponse(['error' => 'Invalid file'], 400);
        }
        
        $allowedMimes = ['image/jpeg', 'image/png', 'application/pdf'];
        if (!in_array($file->getMimeType(), $allowedMimes)) {
            return new JsonResponse(['error' => 'Invalid type'], 400);
        }
        
        $uniqueName = uniqid() . '.' . $file->guessExtension();
        $file->move('uploads/', $uniqueName);
        
        return new JsonResponse(['filename' => $uniqueName]);
    }
}
```

---

## Kotlin

### Ktor Content.MultiPart (Recommended)

```kotlin
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import java.io.File
import java.util.UUID

fun Application.configureFileRoutes() {
    routing {
        post("/upload") {
            val multipart = call.receiveMultipart()
            var filename: String? = null
            
            multipart.forEachPart { part ->
                when (part) {
                    is PartData.FileItem -> {
                        val fileBytes = part.streamProvider().readBytes()
                        if (fileBytes.size > 5 * 1024 * 1024) {
                            call.respond(HttpStatusCode.BadRequest, "File too large")
                            return@post
                        }
                        
                        val ext = File(part.originalFileName ?: "").extension
                        filename = "${UUID.randomUUID()}.$ext"
                        File("uploads/$filename").writeBytes(fileBytes)
                    }
                    else -> {}
                }
                part.dispose()
            }
            
            call.respond(mapOf("filename" to filename))
        }
        
        get("/download/{filename}") {
            val filename = call.parameters["filename"]!!
            val file = File("uploads/$filename")
            
            if (!file.exists()) {
                call.respond(HttpStatusCode.NotFound)
                return@get
            }
            
            call.respondFile(file)
        }
    }
}
```

---

## Swift

### Vapor FileIO (Recommended)

```swift
import Vapor

func routes(_ app: Application) throws {
    app.post("upload") { req async throws -> UploadResponse in
        let file = try req.content.decode(FileUpload.self)
        
        guard file.file.data.readableBytes <= 5 * 1024 * 1024 else {
            throw Abort(.badRequest, reason: "File too large")
        }
        
        let allowedTypes = ["image/jpeg", "image/png", "application/pdf"]
        guard allowedTypes.contains(file.file.contentType?.description ?? "") else {
            throw Abort(.badRequest, reason: "Invalid file type")
        }
        
        let uniqueName = "\(UUID().uuidString).\(file.file.extension ?? "")"
        let path = "uploads/\(uniqueName)"
        
        try await req.fileio.writeFile(file.file.data, at: path)
        
        return UploadResponse(filename: uniqueName)
    }
    
    app.get("download", ":filename") { req async throws -> Response in
        guard let filename = req.parameters.get("filename") else {
            throw Abort(.badRequest)
        }
        
        let path = "uploads/\(filename)"
        return req.fileio.streamFile(at: path)
    }
}

struct FileUpload: Content {
    var file: File
}

struct UploadResponse: Content {
    let filename: String
}
```

---

## Dart

### MultipartFile (http) - Recommended

```dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:uuid/uuid.dart';

Future<Response> uploadFile(Request request) async {
  if (!request.isMultipart) {
    return Response.badRequest(body: 'Not multipart');
  }
  
  await for (final formData in request.multipartFormData) {
    if (formData.name == 'file') {
      final filename = formData.filename ?? 'unknown';
      final contentType = formData.contentType?.mimeType ?? '';
      
      final allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
      if (!allowedTypes.contains(contentType)) {
        return Response.badRequest(body: 'Invalid file type');
      }
      
      final bytes = await formData.part.readBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        return Response.badRequest(body: 'File too large');
      }
      
      final ext = filename.split('.').last;
      final uniqueName = '${Uuid().v4()}.$ext';
      final file = File('uploads/$uniqueName');
      
      await file.writeAsBytes(bytes);
      
      return Response.ok('{"filename": "$uniqueName"}',
          headers: {'content-type': 'application/json'});
    }
  }
  
  return Response.badRequest(body: 'No file uploaded');
}

Future<Response> downloadFile(Request request, String filename) async {
  final file = File('uploads/$filename');
  
  if (!await file.exists()) {
    return Response.notFound('File not found');
  }
  
  final bytes = await file.readAsBytes();
  return Response.ok(bytes, headers: {
    'content-type': 'application/octet-stream',
    'content-disposition': 'attachment; filename="$filename"',
  });
}
```

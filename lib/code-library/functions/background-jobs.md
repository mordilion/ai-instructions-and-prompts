---
title: Background Jobs & Queues Patterns
category: Async Processing
difficulty: intermediate
purpose: Asynchronous job processing, task queuing, and scheduled tasks
when_to_use:
  - Email sending without blocking HTTP requests
  - Image processing and thumbnail generation
  - Report generation and PDF creation
  - Data import/export operations
  - Scheduled cleanup or maintenance tasks
languages:
  typescript:
    - name: BullMQ
      library: bullmq
      recommended: true
    - name: Agenda
      library: agenda
    - name: node-cron
      library: node-cron
  python:
    - name: Celery
      library: celery
      recommended: true
    - name: RQ (Redis Queue)
      library: rq
    - name: APScheduler
      library: apscheduler
  java:
    - name: Spring @Async
      library: spring-boot
      recommended: true
    - name: Quartz Scheduler
      library: quartz
    - name: JobRunr
      library: jobrunr
  csharp:
    - name: Hangfire
      library: Hangfire
      recommended: true
    - name: Quartz.NET
      library: Quartz
  php:
    - name: Laravel Queues
      library: laravel/framework
      recommended: true
    - name: Symfony Messenger
      library: symfony/messenger
  kotlin:
    - name: Spring @Async
      library: spring-boot
      recommended: true
    - name: Quartz
      library: quartz
  swift:
    - name: Queues (Vapor)
      library: vapor/queues
      recommended: true
    - name: DispatchQueue
      library: Foundation
  dart:
    - name: Worker Isolates
      library: dart:isolate
      recommended: true
    - name: dart_job_scheduler
      library: dart_job_scheduler
common_patterns:
  - Queue jobs for async processing
  - Retry failed jobs with exponential backoff
  - Schedule recurring tasks (cron-like)
  - Process jobs in background workers
  - Monitor job status and progress
best_practices:
  do:
    - Use message queues for durability (Redis, RabbitMQ)
    - Implement exponential backoff for retries
    - Set max retry limits
    - Log job failures with context
    - Make jobs idempotent (safe to retry)
    - Monitor queue depth and processing time
    - Use dead letter queues for failed jobs
  dont:
    - Process long tasks in HTTP requests
    - Retry indefinitely without max limit
    - Store large data in queue messages
    - Skip job uniqueness checks for critical operations
    - Ignore failed jobs
related_functions:
  - async-operations.md
  - error-handling.md
  - logging.md
tags: [background-jobs, queues, scheduling, async, workers]
updated: 2026-01-20
---

## TypeScript

### BullMQ (Recommended)

```typescript
import { Queue, Worker, Job } from 'bullmq';
import Redis from 'ioredis';

const connection = new Redis();

// Define queue
const emailQueue = new Queue('email', { connection });

// Add job to queue
export async function sendEmailAsync(to: string, subject: string, body: string) {
  await emailQueue.add('send-email', {
    to,
    subject,
    body
  }, {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000 // Start with 2s, then 4s, 8s
    },
    removeOnComplete: true,
    removeOnFail: 100 // Keep last 100 failed jobs
  });
}

// Worker to process jobs
const worker = new Worker('email', async (job: Job) => {
  const { to, subject, body } = job.data;
  
  console.log(`Processing job ${job.id}: sending email to ${to}`);
  
  // Simulate email sending
  await sendEmail(to, subject, body);
  
  return { sent: true, to };
}, { connection });

worker.on('completed', (job) => {
  console.log(`Job ${job.id} completed`);
});

worker.on('failed', (job, err) => {
  console.error(`Job ${job?.id} failed:`, err);
});
```

### Scheduled Jobs with BullMQ

```typescript
// Schedule recurring job (cron-like)
await emailQueue.add('weekly-report', {
  reportType: 'weekly'
}, {
  repeat: {
    pattern: '0 9 * * 1' // Every Monday at 9 AM
  }
});

// One-time delayed job
await emailQueue.add('reminder', {
  userId: '123',
  message: 'Your trial expires in 3 days'
}, {
  delay: 3 * 24 * 60 * 60 * 1000 // 3 days
});
```

---

## Python

### Celery (Recommended)

```python
from celery import Celery
from celery.schedules import crontab

app = Celery('tasks', broker='redis://localhost:6379/0')

# Configure
app.conf.update(
    task_serializer='json',
    result_backend='redis://localhost:6379/0',
    task_track_started=True,
    task_time_limit=300,  # 5 minutes
    task_soft_time_limit=240,  # 4 minutes warning
)

@app.task(bind=True, max_retries=3)
def send_email(self, to: str, subject: str, body: str):
    try:
        print(f"Sending email to {to}")
        # Simulate email sending
        import smtplib
        # ... email logic ...
        return {"sent": True, "to": to}
    except Exception as exc:
        # Retry with exponential backoff
        raise self.retry(exc=exc, countdown=2 ** self.request.retries)

# Call task asynchronously
send_email.delay("user@example.com", "Hello", "Welcome!")

# Call with delay
send_email.apply_async(
    args=["user@example.com", "Reminder", "..."],
    countdown=3600  # 1 hour delay
)
```

### Scheduled Tasks with Celery Beat

```python
from celery.schedules import crontab

app.conf.beat_schedule = {
    'send-weekly-report': {
        'task': 'tasks.generate_weekly_report',
        'schedule': crontab(hour=9, minute=0, day_of_week=1),  # Monday 9 AM
    },
    'cleanup-old-files': {
        'task': 'tasks.cleanup_files',
        'schedule': crontab(hour=2, minute=0),  # Every day at 2 AM
    },
}

@app.task
def generate_weekly_report():
    print("Generating weekly report...")
    # Report logic
```

### RQ (Redis Queue) - Simpler Alternative

```python
from redis import Redis
from rq import Queue
from rq.job import Job

redis_conn = Redis()
queue = Queue(connection=redis_conn)

def send_email(to, subject, body):
    print(f"Sending email to {to}")
    # Email logic
    return {"sent": True}

# Enqueue job
job = queue.enqueue(
    send_email,
    args=('user@example.com', 'Hello', 'Welcome!'),
    retry=Retry(max=3, interval=[10, 30, 60])
)

# Check job status
job = Job.fetch(job.id, connection=redis_conn)
print(job.get_status())  # queued, started, finished, failed
```

---

## Java

### Spring @Async (Recommended)

```java
import org.springframework.scheduling.annotation.*;
import org.springframework.retry.annotation.Retryable;
import org.springframework.retry.annotation.Backoff;
import java.util.concurrent.CompletableFuture;

@Configuration
@EnableAsync
@EnableScheduling
public class AsyncConfig {
    @Bean
    public TaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}

@Service
public class EmailService {
    
    @Async
    @Retryable(
        value = {EmailException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 2000, multiplier = 2)
    )
    public CompletableFuture<Boolean> sendEmailAsync(
            String to, String subject, String body) {
        
        log.info("Sending email to {}", to);
        
        // Email logic here
        emailSender.send(to, subject, body);
        
        return CompletableFuture.completedFuture(true);
    }
    
    // Scheduled task
    @Scheduled(cron = "0 0 9 * * MON") // Every Monday at 9 AM
    public void weeklyReport() {
        log.info("Generating weekly report");
        // Report logic
    }
    
    @Scheduled(fixedRate = 3600000) // Every hour
    public void cleanupOldFiles() {
        log.info("Cleaning up old files");
        // Cleanup logic
    }
}
```

### Quartz Scheduler (for complex scheduling)

```java
import org.quartz.*;

@Component
public class EmailJob implements Job {
    @Override
    public void execute(JobExecutionContext context) {
        JobDataMap data = context.getMergedJobDataMap();
        String to = data.getString("to");
        
        log.info("Executing email job for {}", to);
        // Email logic
    }
}

@Configuration
public class QuartzConfig {
    @Bean
    public JobDetail emailJobDetail() {
        return JobBuilder.newJob(EmailJob.class)
            .withIdentity("emailJob")
            .storeDurably()
            .build();
    }
    
    @Bean
    public Trigger emailTrigger() {
        return TriggerBuilder.newTrigger()
            .forJob(emailJobDetail())
            .withIdentity("emailTrigger")
            .withSchedule(CronScheduleBuilder.cronSchedule("0 0 9 * * ?"))
            .build();
    }
}
```

---

## C#

### Hangfire (Recommended)

```csharp
using Hangfire;
using Hangfire.SqlServer;

// Startup configuration
public void ConfigureServices(IServiceCollection services)
{
    services.AddHangfire(config => config
        .SetDataCompatibilityLevel(CompatibilityLevel.Version_170)
        .UseSimpleAssemblyNameTypeSerializer()
        .UseRecommendedSerializerSettings()
        .UseSqlServerStorage(Configuration.GetConnectionString("HangfireConnection")));
    
    services.AddHangfireServer();
}

// Enqueue background job
public class EmailService
{
    public void SendEmailAsync(string to, string subject, string body)
    {
        BackgroundJob.Enqueue(() => SendEmail(to, subject, body));
    }
    
    public void SendEmail(string to, string subject, string body)
    {
        Console.WriteLine($"Sending email to {to}");
        // Email logic
    }
    
    // Schedule delayed job
    public void SendReminderLater(string to, string message)
    {
        BackgroundJob.Schedule(
            () => SendEmail(to, "Reminder", message),
            TimeSpan.FromDays(3)
        );
    }
    
    // Recurring job
    public void SetupRecurringJobs()
    {
        RecurringJob.AddOrUpdate(
            "weekly-report",
            () => GenerateWeeklyReport(),
            Cron.Weekly(DayOfWeek.Monday, 9)
        );
        
        RecurringJob.AddOrUpdate(
            "cleanup",
            () => CleanupOldFiles(),
            Cron.Daily(2)
        );
    }
}
```

### Automatic Retry with Hangfire

```csharp
[AutomaticRetry(Attempts = 3, DelaysInSeconds = new[] { 10, 30, 60 })]
public void ProcessOrder(int orderId)
{
    Console.WriteLine($"Processing order {orderId}");
    // Order logic that might fail
}
```

---

## PHP

### Laravel Queues (Recommended)

```php
<?php

// Job class
namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendEmailJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;
    
    public $tries = 3;
    public $backoff = [10, 30, 60]; // seconds
    
    public function __construct(
        private string $to,
        private string $subject,
        private string $body
    ) {}
    
    public function handle(): void
    {
        Log::info("Sending email to {$this->to}");
        
        Mail::raw($this->body, function ($message) {
            $message->to($this->to)
                    ->subject($this->subject);
        });
    }
    
    public function failed(\Throwable $exception): void
    {
        Log::error("Email job failed: {$exception->getMessage()}");
    }
}

// Dispatch job
SendEmailJob::dispatch('user@example.com', 'Hello', 'Welcome!');

// Dispatch with delay
SendEmailJob::dispatch($to, $subject, $body)
    ->delay(now()->addHours(1));

// Dispatch on specific queue
SendEmailJob::dispatch($to, $subject, $body)
    ->onQueue('emails');
```

### Laravel Scheduled Tasks

```php
<?php

// app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    $schedule->call(function () {
        Log::info('Generating weekly report');
        // Report logic
    })->weeklyOn(1, '9:00'); // Monday at 9 AM
    
    $schedule->command('cleanup:old-files')
        ->daily()
        ->at('02:00');
    
    $schedule->job(new ProcessReports)
        ->hourly();
}
```

---

## Kotlin

### Spring @Async (Recommended)

```kotlin
import org.springframework.scheduling.annotation.*
import org.springframework.retry.annotation.*
import kotlinx.coroutines.*

@Configuration
@EnableAsync
@EnableScheduling
class AsyncConfig

@Service
class EmailService {
    
    @Async
    @Retryable(
        value = [EmailException::class],
        maxAttempts = 3,
        backoff = Backoff(delay = 2000, multiplier = 2.0)
    )
    fun sendEmailAsync(to: String, subject: String, body: String): CompletableFuture<Boolean> {
        log.info("Sending email to $to")
        
        // Email logic
        emailSender.send(to, subject, body)
        
        return CompletableFuture.completedFuture(true)
    }
    
    @Scheduled(cron = "0 0 9 * * MON")
    fun weeklyReport() {
        log.info("Generating weekly report")
        // Report logic
    }
    
    @Scheduled(fixedRate = 3600000)
    fun cleanupOldFiles() {
        log.info("Cleaning up old files")
        // Cleanup logic
    }
}
```

---

## Swift

### Queues (Vapor) - Recommended

```swift
import Vapor
import Queues

// Configure queues
app.queues.use(.redis(url: "redis://localhost:6379"))

// Define job
struct EmailJob: AsyncJob {
    let to: String
    let subject: String
    let body: String
    
    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        context.logger.info("Sending email to \(payload.to)")
        
        // Email logic
        try await sendEmail(
            to: payload.to,
            subject: payload.subject,
            body: payload.body
        )
    }
    
    func error(_ context: QueueContext, _ error: Error, _ payload: Payload) async throws {
        context.logger.error("Email job failed: \(error)")
    }
}

// Register job
app.queues.add(EmailJob())

// Dispatch job
app.post("send-email") { req async throws -> HTTPStatus in
    let email = try req.content.decode(EmailRequest.self)
    
    try await req.queue.dispatch(
        EmailJob.self,
        .init(to: email.to, subject: email.subject, body: email.body),
        maxRetryCount: 3
    )
    
    return .accepted
}

// Scheduled job
app.queues.schedule(EmailJob())
    .weekly()
    .on(.monday)
    .at(.init(hour: 9, minute: 0))
```

---

## Dart

### Worker Isolates (Recommended)

```dart
import 'dart:isolate';
import 'dart:async';

class BackgroundJobQueue {
  final SendPort _sendPort;
  
  BackgroundJobQueue(this._sendPort);
  
  static Future<BackgroundJobQueue> create() async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(_worker, receivePort.sendPort);
    
    final sendPort = await receivePort.first as SendPort;
    return BackgroundJobQueue(sendPort);
  }
  
  void enqueue(Map<String, dynamic> job) {
    _sendPort.send(job);
  }
  
  static void _worker(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    
    await for (final job in receivePort) {
      if (job is Map<String, dynamic>) {
        await _processJob(job);
      }
    }
  }
  
  static Future<void> _processJob(Map<String, dynamic> job) async {
    print('Processing job: ${job['type']}');
    
    try {
      switch (job['type']) {
        case 'send_email':
          await _sendEmail(job['to'], job['subject'], job['body']);
          break;
        default:
          print('Unknown job type: ${job['type']}');
      }
    } catch (e) {
      print('Job failed: $e');
      // Could implement retry logic here
    }
  }
  
  static Future<void> _sendEmail(String to, String subject, String body) async {
    print('Sending email to $to');
    // Email logic
    await Future.delayed(Duration(seconds: 1));
  }
}

// Usage
void main() async {
  final queue = await BackgroundJobQueue.create();
  
  queue.enqueue({
    'type': 'send_email',
    'to': 'user@example.com',
    'subject': 'Hello',
    'body': 'Welcome!'
  });
}
```

### Scheduled Tasks with Timer

```dart
import 'dart:async';

class TaskScheduler {
  void scheduleRecurring(Duration interval, Function() task) {
    Timer.periodic(interval, (timer) {
      task();
    });
  }
  
  void scheduleOnce(Duration delay, Function() task) {
    Timer(delay, task);
  }
}

// Usage
final scheduler = TaskScheduler();

// Run every hour
scheduler.scheduleRecurring(
  Duration(hours: 1),
  () => cleanupOldFiles()
);

// Run once after 3 days
scheduler.scheduleOnce(
  Duration(days: 3),
  () => sendReminder('user@example.com')
);
```

---
title: Email Sending Patterns
category: Communication
difficulty: intermediate
purpose: Send transactional emails with templates, attachments, and proper error handling
when_to_use:
  - User registration and verification emails
  - Password reset emails
  - Order confirmations and receipts
  - Notification emails
  - Marketing campaigns
languages:
  typescript:
    - name: Nodemailer
      library: nodemailer
      recommended: true
    - name: SendGrid
      library: "@sendgrid/mail"
    - name: AWS SES
      library: "@aws-sdk/client-ses"
  python:
    - name: Django Email
      library: django
      recommended: true
    - name: FastAPI + email-validator
      library: email-validator
    - name: smtplib (Native)
      library: python-stdlib
  java:
    - name: Spring JavaMailSender
      library: spring-boot-starter-mail
      recommended: true
    - name: Apache Commons Email
      library: commons-email
  csharp:
    - name: MailKit
      library: MailKit
      recommended: true
    - name: SmtpClient (Native)
      library: System.Net.Mail
  php:
    - name: Laravel Mail
      library: laravel/framework
      recommended: true
    - name: Symfony Mailer
      library: symfony/mailer
    - name: PHPMailer
      library: phpmailer/phpmailer
  kotlin:
    - name: Spring JavaMailSender
      library: spring-boot-starter-mail
      recommended: true
    - name: Apache Commons Email
      library: commons-email
  swift:
    - name: Vapor (SMTP)
      library: vapor/smtp-kit
      recommended: true
    - name: SwiftMailer
      library: SwiftMailer
  dart:
    - name: mailer
      library: mailer
      recommended: true
    - name: sendgrid_mailer
      library: sendgrid_mailer
common_patterns:
  - Use environment variables for SMTP credentials
  - Render HTML templates for rich emails
  - Include plain text alternative
  - Validate email addresses before sending
  - Handle attachments securely
best_practices:
  do:
    - Use TLS/SSL for SMTP connections
    - Validate email format before sending
    - Include both HTML and plain text versions
    - Use email templates for consistency
    - Log email sending failures
    - Rate limit to avoid spam filters
    - Use transactional email services for reliability
    - Include unsubscribe links for marketing
  dont:
    - Send emails synchronously in HTTP requests
    - Store SMTP credentials in code
    - Skip email validation
    - Send HTML-only emails (accessibility)
    - Expose recipient emails in CC (use BCC)
    - Ignore bounce and complaint notifications
related_functions:
  - background-jobs.md
  - config-secrets.md
  - error-handling.md
tags: [email, smtp, notifications, templates, communication]
updated: 2026-01-20
---

## TypeScript

### Nodemailer (Recommended)

```typescript
import nodemailer from 'nodemailer';
import { readFile } from 'fs/promises';

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: false, // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  }
});

async function sendEmail(to: string, subject: string, html: string, text?: string) {
  try {
    const info = await transporter.sendMail({
      from: `"Your App" <${process.env.SMTP_FROM}>`,
      to,
      subject,
      html,
      text: text || html.replace(/<[^>]*>/g, '') // Strip HTML as fallback
    });
    
    console.log('Email sent:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Email failed:', error);
    throw new Error(`Failed to send email: ${error.message}`);
  }
}

// With template
async function sendWelcomeEmail(to: string, name: string) {
  const template = await readFile('./templates/welcome.html', 'utf-8');
  const html = template
    .replace('{{name}}', name)
    .replace('{{year}}', new Date().getFullYear().toString());
  
  return sendEmail(to, 'Welcome to Our App!', html);
}

// With attachment
async function sendInvoice(to: string, invoicePath: string) {
  const info = await transporter.sendMail({
    from: process.env.SMTP_FROM,
    to,
    subject: 'Your Invoice',
    html: '<p>Please find your invoice attached.</p>',
    attachments: [
      {
        filename: 'invoice.pdf',
        path: invoicePath
      }
    ]
  });
  
  return info;
}
```

### SendGrid API

```typescript
import sgMail from '@sendgrid/mail';

sgMail.setApiKey(process.env.SENDGRID_API_KEY!);

async function sendEmailSendGrid(to: string, subject: string, html: string) {
  const msg = {
    to,
    from: process.env.SENDGRID_FROM!,
    subject,
    html,
    text: html.replace(/<[^>]*>/g, '')
  };
  
  try {
    await sgMail.send(msg);
    console.log('Email sent via SendGrid');
    return { success: true };
  } catch (error) {
    console.error('SendGrid error:', error);
    throw error;
  }
}

// With template
async function sendTemplatedEmail(to: string, templateId: string, data: any) {
  await sgMail.send({
    to,
    from: process.env.SENDGRID_FROM!,
    templateId,
    dynamicTemplateData: data
  });
}
```

---

## Python

### Django Email (Recommended)

```python
from django.core.mail import EmailMessage, send_mail
from django.template.loader import render_to_string
from django.conf import settings

def send_simple_email(to: str, subject: str, message: str):
    send_mail(
        subject=subject,
        message=message,
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[to],
        fail_silently=False,
    )

def send_html_email(to: str, subject: str, template: str, context: dict):
    html_content = render_to_string(template, context)
    plain_content = html_content.replace('<[^>]*>', '')  # Strip HTML
    
    email = EmailMessage(
        subject=subject,
        body=plain_content,
        from_email=settings.DEFAULT_FROM_EMAIL,
        to=[to],
    )
    email.content_subtype = 'html'
    email.send()

def send_welcome_email(to: str, name: str):
    context = {
        'name': name,
        'year': datetime.now().year,
    }
    send_html_email(
        to=to,
        subject='Welcome to Our App!',
        template='emails/welcome.html',
        context=context
    )

def send_email_with_attachment(to: str, subject: str, body: str, file_path: str):
    email = EmailMessage(
        subject=subject,
        body=body,
        from_email=settings.DEFAULT_FROM_EMAIL,
        to=[to],
    )
    email.attach_file(file_path)
    email.send()
```

### FastAPI with smtplib

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from pathlib import Path

def send_email(to: str, subject: str, html: str, text: str = None):
    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = os.getenv('SMTP_FROM')
    msg['To'] = to
    
    # Add plain text version
    if text:
        msg.attach(MIMEText(text, 'plain'))
    
    # Add HTML version
    msg.attach(MIMEText(html, 'html'))
    
    try:
        with smtplib.SMTP(os.getenv('SMTP_HOST'), int(os.getenv('SMTP_PORT'))) as server:
            server.starttls()
            server.login(os.getenv('SMTP_USER'), os.getenv('SMTP_PASS'))
            server.send_message(msg)
        
        return {"success": True}
    except Exception as e:
        print(f"Email failed: {e}")
        raise

def send_email_with_attachment(to: str, subject: str, body: str, file_path: Path):
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['From'] = os.getenv('SMTP_FROM')
    msg['To'] = to
    
    msg.attach(MIMEText(body, 'html'))
    
    # Attach file
    with open(file_path, 'rb') as f:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(f.read())
        encoders.encode_base64(part)
        part.add_header(
            'Content-Disposition',
            f'attachment; filename={file_path.name}'
        )
        msg.attach(part)
    
    with smtplib.SMTP(os.getenv('SMTP_HOST'), int(os.getenv('SMTP_PORT'))) as server:
        server.starttls()
        server.login(os.getenv('SMTP_USER'), os.getenv('SMTP_PASS'))
        server.send_message(msg)
```

---

## Java

### Spring JavaMailSender (Recommended)

```java
import org.springframework.mail.javamail.*;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import javax.mail.internet.MimeMessage;
import javax.mail.MessagingException;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring5.SpringTemplateEngine;

@Service
public class EmailService {
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Autowired
    private SpringTemplateEngine templateEngine;
    
    @Value("${spring.mail.username}")
    private String fromEmail;
    
    public void sendSimpleEmail(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);
        
        mailSender.send(message);
    }
    
    public void sendHtmlEmail(String to, String subject, String htmlBody) 
            throws MessagingException {
        
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        
        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlBody, true); // true = HTML
        
        mailSender.send(message);
    }
    
    public void sendWelcomeEmail(String to, String name) throws MessagingException {
        Context context = new Context();
        context.setVariable("name", name);
        context.setVariable("year", Year.now().getValue());
        
        String htmlBody = templateEngine.process("welcome", context);
        
        sendHtmlEmail(to, "Welcome to Our App!", htmlBody);
    }
    
    public void sendEmailWithAttachment(
            String to, String subject, String body, File attachment) 
            throws MessagingException {
        
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        
        helper.setFrom(fromEmail);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(body, true);
        helper.addAttachment(attachment.getName(), attachment);
        
        mailSender.send(message);
    }
}
```

---

## C#

### MailKit (Recommended)

```csharp
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

public class EmailService
{
    private readonly IConfiguration _config;
    
    public EmailService(IConfiguration config)
    {
        _config = config;
    }
    
    public async Task SendEmailAsync(string to, string subject, string htmlBody, string textBody = null)
    {
        var message = new MimeMessage();
        message.From.Add(new MailboxAddress("Your App", _config["Smtp:From"]));
        message.To.Add(MailboxAddress.Parse(to));
        message.Subject = subject;
        
        var builder = new BodyBuilder
        {
            HtmlBody = htmlBody,
            TextBody = textBody ?? StripHtml(htmlBody)
        };
        
        message.Body = builder.ToMessageBody();
        
        using var client = new SmtpClient();
        try
        {
            await client.ConnectAsync(_config["Smtp:Host"], 
                int.Parse(_config["Smtp:Port"]), SecureSocketOptions.StartTls);
            
            await client.AuthenticateAsync(_config["Smtp:User"], _config["Smtp:Pass"]);
            
            await client.SendAsync(message);
            
            await client.DisconnectAsync(true);
        }
        catch (Exception ex)
        {
            throw new Exception($"Failed to send email: {ex.Message}", ex);
        }
    }
    
    public async Task SendWelcomeEmailAsync(string to, string name)
    {
        var html = $@"
            <h1>Welcome {name}!</h1>
            <p>Thank you for joining our app.</p>
            <p>Get started by exploring our features.</p>
        ";
        
        await SendEmailAsync(to, "Welcome to Our App!", html);
    }
    
    public async Task SendEmailWithAttachmentAsync(
        string to, string subject, string body, string filePath)
    {
        var message = new MimeMessage();
        message.From.Add(new MailboxAddress("Your App", _config["Smtp:From"]));
        message.To.Add(MailboxAddress.Parse(to));
        message.Subject = subject;
        
        var builder = new BodyBuilder { HtmlBody = body };
        builder.Attachments.Add(filePath);
        
        message.Body = builder.ToMessageBody();
        
        using var client = new SmtpClient();
        await client.ConnectAsync(_config["Smtp:Host"], 
            int.Parse(_config["Smtp:Port"]), SecureSocketOptions.StartTls);
        await client.AuthenticateAsync(_config["Smtp:User"], _config["Smtp:Pass"]);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
    
    private string StripHtml(string html)
    {
        return System.Text.RegularExpressions.Regex.Replace(html, "<.*?>", string.Empty);
    }
}
```

---

## PHP

### Laravel Mail (Recommended)

```php
<?php

use Illuminate\Support\Facades\Mail;
use Illuminate\Mail\Mailable;

// Simple email
Mail::raw('Hello, welcome to our app!', function ($message) {
    $message->to('user@example.com')
            ->subject('Welcome');
});

// HTML email
Mail::send('emails.welcome', ['name' => 'John'], function ($message) {
    $message->to('user@example.com')
            ->subject('Welcome to Our App!');
});

// Mailable class (recommended)
namespace App\Mail;

class WelcomeEmail extends Mailable
{
    public function __construct(public string $name) {}
    
    public function build()
    {
        return $this->view('emails.welcome')
                    ->subject('Welcome to Our App!')
                    ->with(['name' => $this->name]);
    }
}

// Send mailable
Mail::to('user@example.com')->send(new WelcomeEmail('John'));

// With attachment
class InvoiceEmail extends Mailable
{
    public function __construct(public string $invoicePath) {}
    
    public function build()
    {
        return $this->view('emails.invoice')
                    ->subject('Your Invoice')
                    ->attach($this->invoicePath, [
                        'as' => 'invoice.pdf',
                        'mime' => 'application/pdf',
                    ]);
    }
}

// Queue email (non-blocking)
Mail::to('user@example.com')->queue(new WelcomeEmail('John'));
```

### Symfony Mailer

```php
<?php

use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;

class EmailService
{
    public function __construct(private MailerInterface $mailer) {}
    
    public function sendEmail(string $to, string $subject, string $html): void
    {
        $email = (new Email())
            ->from('noreply@example.com')
            ->to($to)
            ->subject($subject)
            ->html($html);
        
        $this->mailer->send($email);
    }
    
    public function sendWelcomeEmail(string $to, string $name): void
    {
        $html = <<<HTML
            <h1>Welcome {$name}!</h1>
            <p>Thank you for joining our app.</p>
        HTML;
        
        $this->sendEmail($to, 'Welcome!', $html);
    }
    
    public function sendWithAttachment(string $to, string $subject, string $body, string $filePath): void
    {
        $email = (new Email())
            ->from('noreply@example.com')
            ->to($to)
            ->subject($subject)
            ->html($body)
            ->attachFromPath($filePath);
        
        $this->mailer->send($email);
    }
}
```

---

## Kotlin

### Spring JavaMailSender (Recommended)

```kotlin
import org.springframework.mail.javamail.*
import org.springframework.stereotype.Service
import org.thymeleaf.context.Context
import org.thymeleaf.spring5.SpringTemplateEngine
import javax.mail.internet.MimeMessage

@Service
class EmailService(
    private val mailSender: JavaMailSender,
    private val templateEngine: SpringTemplateEngine,
    @Value("\${spring.mail.username}") private val fromEmail: String
) {
    
    fun sendHtmlEmail(to: String, subject: String, htmlBody: String) {
        val message: MimeMessage = mailSender.createMimeMessage()
        val helper = MimeMessageHelper(message, true, "UTF-8")
        
        helper.setFrom(fromEmail)
        helper.setTo(to)
        helper.setSubject(subject)
        helper.setText(htmlBody, true)
        
        mailSender.send(message)
    }
    
    fun sendWelcomeEmail(to: String, name: String) {
        val context = Context().apply {
            setVariable("name", name)
            setVariable("year", java.time.Year.now().value)
        }
        
        val htmlBody = templateEngine.process("welcome", context)
        
        sendHtmlEmail(to, "Welcome to Our App!", htmlBody)
    }
    
    fun sendEmailWithAttachment(
        to: String,
        subject: String,
        body: String,
        attachment: File
    ) {
        val message = mailSender.createMimeMessage()
        val helper = MimeMessageHelper(message, true)
        
        helper.setFrom(fromEmail)
        helper.setTo(to)
        helper.setSubject(subject)
        helper.setText(body, true)
        helper.addAttachment(attachment.name, attachment)
        
        mailSender.send(message)
    }
}
```

---

## Swift

### Vapor SMTP (Recommended)

```swift
import Vapor
import SMTPKit

func configure(_ app: Application) throws {
    app.smtp.configuration.hostname = Environment.get("SMTP_HOST")!
    app.smtp.configuration.port = Int(Environment.get("SMTP_PORT")!)!
    app.smtp.configuration.username = Environment.get("SMTP_USER")!
    app.smtp.configuration.password = Environment.get("SMTP_PASS")!
}

func sendEmail(
    to: String,
    subject: String,
    body: String,
    on req: Request
) async throws {
    let email = Email(
        from: EmailAddress(address: Environment.get("SMTP_FROM")!, name: "Your App"),
        to: [EmailAddress(address: to)],
        subject: subject,
        body: body
    )
    
    try await req.smtp.send(email)
}

func sendWelcomeEmail(to: String, name: String, on req: Request) async throws {
    let html = """
    <h1>Welcome \(name)!</h1>
    <p>Thank you for joining our app.</p>
    """
    
    try await sendEmail(
        to: to,
        subject: "Welcome to Our App!",
        body: html,
        on: req
    )
}

func sendEmailWithAttachment(
    to: String,
    subject: String,
    body: String,
    attachmentPath: String,
    on req: Request
) async throws {
    let fileData = try Data(contentsOf: URL(fileURLWithPath: attachmentPath))
    
    let email = Email(
        from: EmailAddress(address: Environment.get("SMTP_FROM")!, name: "Your App"),
        to: [EmailAddress(address: to)],
        subject: subject,
        body: body,
        attachments: [
            Attachment(
                filename: URL(fileURLWithPath: attachmentPath).lastPathComponent,
                data: fileData
            )
        ]
    )
    
    try await req.smtp.send(email)
}
```

---

## Dart

### mailer (Recommended)

```dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final SmtpServer _smtpServer;
  final String _fromEmail;
  
  EmailService()
      : _smtpServer = SmtpServer(
          Platform.environment['SMTP_HOST']!,
          port: int.parse(Platform.environment['SMTP_PORT']!),
          username: Platform.environment['SMTP_USER'],
          password: Platform.environment['SMTP_PASS'],
        ),
        _fromEmail = Platform.environment['SMTP_FROM']!;
  
  Future<void> sendEmail(String to, String subject, String html, {String? text}) async {
    final message = Message()
      ..from = Address(_fromEmail, 'Your App')
      ..recipients.add(to)
      ..subject = subject
      ..html = html
      ..text = text ?? _stripHtml(html);
    
    try {
      final sendReport = await send(message, _smtpServer);
      print('Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Email failed: $e');
      rethrow;
    }
  }
  
  Future<void> sendWelcomeEmail(String to, String name) async {
    final html = '''
      <h1>Welcome $name!</h1>
      <p>Thank you for joining our app.</p>
    ''';
    
    await sendEmail(to, 'Welcome to Our App!', html);
  }
  
  Future<void> sendEmailWithAttachment(
    String to,
    String subject,
    String body,
    String filePath,
  ) async {
    final file = File(filePath);
    final message = Message()
      ..from = Address(_fromEmail, 'Your App')
      ..recipients.add(to)
      ..subject = subject
      ..html = body
      ..attachments = [
        FileAttachment(file)
          ..fileName = path.basename(filePath)
      ];
    
    await send(message, _smtpServer);
  }
  
  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
```

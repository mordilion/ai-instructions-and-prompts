# Django Framework

> **Scope**: Django 4+ applications  
> **Applies to**: Python files in Django projects
> **Extends**: python/architecture.md, python/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Django ORM querysets
> **ALWAYS**: Use Django forms or serializers
> **ALWAYS**: Use CBVs or FBVs consistently
> **ALWAYS**: Use Django's built-in authentication
> **ALWAYS**: Use migrations for schema changes
> 
> **NEVER**: Use raw SQL without parameterization
> **NEVER**: Skip CSRF protection
> **NEVER**: Store sensitive data in settings.py
> **NEVER**: Use syncdb (deprecated)
> **NEVER**: Query in templates

## Core Patterns

### Model

```python
from django.db import models

class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    author = models.ForeignKey('auth.User', on_delete=models.CASCADE, related_name='posts')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [models.Index(fields=['-created_at'])]
    
    def __str__(self):
        return self.title
```

### Class-Based View

```python
from django.views.generic import ListView, CreateView

class PostListView(ListView):
    model = Post
    template_name = 'posts/list.html'
    context_object_name = 'posts'
    paginate_by = 20
    
    def get_queryset(self):
        return Post.objects.select_related('author').filter(published=True)

class PostCreateView(CreateView):
    model = Post
    fields = ['title', 'content']
    success_url = '/posts/'
```

### Function-Based View

```python
from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse

def post_detail(request, pk):
    post = get_object_or_404(Post.objects.select_related('author'), pk=pk)
    return render(request, 'posts/detail.html', {'post': post})
```

### Django REST Framework

```python
from rest_framework import serializers, viewsets

class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ['id', 'title', 'content', 'created_at']

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.select_related('author')
    serializer_class = PostSerializer
```

### Avoid N+1 Queries

```python
# ❌ WRONG: N+1 queries
posts = Post.objects.all()
for post in posts:
    print(post.author.name)  // Queries author for each post

// ✅ CORRECT: Single query
posts = Post.objects.select_related('author').all()
for post in posts:
    print(post.author.name)

// ✅ CORRECT: Many-to-many
posts = Post.objects.prefetch_related('tags').all()
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Raw SQL** | `cursor.execute(sql)` | ORM with parameterization |
| **N+1 Queries** | Lazy loading | `select_related()` |
| **Template Queries** | `{% for p in user.posts %}` | Pass in view |
| **Settings Secrets** | `SECRET_KEY = 'x'` | Environment variables |

## AI Self-Check

- [ ] Using Django ORM?
- [ ] Forms/serializers for validation?
- [ ] CBV/FBV consistent?
- [ ] Built-in authentication?
- [ ] Migrations for schema?
- [ ] No raw SQL without params?
- [ ] CSRF protection?
- [ ] Env vars for secrets?
- [ ] select_related/prefetch_related?

## Key Features

| Feature | Purpose |
|---------|---------|
| ORM | Database abstraction |
| CBVs | Reusable views |
| DRF | API framework |
| select_related | Avoid N+1 |
| Migrations | Schema versioning |

## Best Practices

**MUST**: ORM, forms/serializers, migrations, authentication, select_related
**SHOULD**: CBVs for CRUD, DRF for APIs, env vars, CSRF protection
**AVOID**: Raw SQL, N+1 queries, template queries, settings secrets

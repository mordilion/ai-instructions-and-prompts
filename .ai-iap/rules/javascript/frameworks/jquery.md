# jQuery

> **Scope**: Apply these rules when working with jQuery for DOM manipulation and AJAX. Consider modern alternatives (vanilla JS, Alpine.js) for new projects.

## 1. When to Use jQuery
- **Legacy Projects**: Maintaining existing jQuery codebases.
- **Quick Prototypes**: Rapid DOM manipulation.
- **Plugin Ecosystem**: Leveraging jQuery plugins.
- **Avoid For**: New SPAs (use React/Vue), modern projects (use vanilla JS).

## 2. Selectors & Caching
```javascript
// ✅ Good - Cache selectors
const $userList = $('#user-list');
const $submitBtn = $('.submit-btn');

// ❌ Bad - Repeated DOM queries
$('#user-list').append(item);
$('#user-list').addClass('loaded');
$('#user-list').show();

// ✅ Good - Chain methods
$('#user-list')
  .append(item)
  .addClass('loaded')
  .show();
```

## 3. Event Handling
```javascript
// Delegated events (preferred for dynamic content)
$(document).on('click', '.delete-btn', function(e) {
  e.preventDefault();
  const id = $(this).data('id');
  deleteItem(id);
});

// Direct binding
$submitBtn.on('click', handleSubmit);

// Namespaced events (easy cleanup)
$element.on('click.myPlugin', handler);
$element.off('click.myPlugin');
```

## 4. AJAX
```javascript
// Modern jQuery AJAX
$.ajax({
  url: '/api/users',
  method: 'POST',
  contentType: 'application/json',
  data: JSON.stringify({ name, email }),
})
  .done(function(response) {
    console.log('Success:', response);
  })
  .fail(function(xhr, status, error) {
    console.error('Error:', error);
  })
  .always(function() {
    $submitBtn.prop('disabled', false);
  });

// Shorthand methods
$.get('/api/users', function(users) { ... });
$.post('/api/users', { name, email }, function(response) { ... });
$.getJSON('/api/users/1', function(user) { ... });
```

## 5. DOM Manipulation
```javascript
// Creating elements
const $card = $('<div>', {
  class: 'card',
  'data-id': user.id,
  html: `<h3>${user.name}</h3><p>${user.email}</p>`
});

// Appending
$('#container').append($card);

// Updating content
$('#status').text('Loading...');
$('#content').html('<p>Loaded content</p>');

// Attributes & Data
$element.attr('href', '/new-url');
$element.data('userId', 123);
const userId = $element.data('userId');
```

## 6. Plugin Pattern
```javascript
(function($) {
  $.fn.tooltip = function(options) {
    const settings = $.extend({
      position: 'top',
      delay: 200
    }, options);

    return this.each(function() {
      const $element = $(this);
      const text = $element.attr('title');
      
      $element
        .removeAttr('title')
        .on('mouseenter', function() {
          // Show tooltip
        })
        .on('mouseleave', function() {
          // Hide tooltip
        });
    });
  };
})(jQuery);

// Usage
$('.has-tooltip').tooltip({ position: 'bottom' });
```

## 7. Best Practices
- **Cache Selectors**: Store jQuery objects in variables.
- **Use Delegation**: For dynamic content.
- **Namespace Events**: For easy cleanup.
- **Avoid `$.each` for Arrays**: Use native `forEach`/`map`.
- **Consider Vanilla JS**: For simple tasks.

```javascript
// ✅ Modern alternative - vanilla JS
document.querySelectorAll('.item').forEach(el => {
  el.classList.add('active');
});

// vs jQuery
$('.item').addClass('active');
```


# jQuery

> **Scope**: jQuery for DOM manipulation and AJAX (legacy projects)  
> **Applies to**: JavaScript files using jQuery  
> **Extends**: javascript/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Cache selectors (store in variables)
> **ALWAYS**: Use event delegation for dynamic content
> **ALWAYS**: Chain methods when possible
> **ALWAYS**: Namespace events for cleanup
> **ALWAYS**: Use $.ajax() promises (not callbacks)
> 
> **NEVER**: Use jQuery for new projects (use vanilla JS/Alpine/React)
> **NEVER**: Repeated DOM queries (cache selectors)
> **NEVER**: $.each for arrays (use native forEach/map)
> **NEVER**: Use document.write
> **NEVER**: Bind events to many elements (use delegation)

## 1. When to Use jQuery
- **Legacy Projects**: Maintaining existing jQuery codebases.
- **Quick Prototypes**: Rapid DOM manipulation.
- **Plugin Ecosystem**: Leveraging jQuery plugins.
- **Avoid For**: New SPAs (use React/Vue), modern projects (use vanilla JS).

## 2. Key Patterns

| Pattern | Example |
|---------|---------|
| **Cache Selectors** | `const $list = $('#list'); $list.append(item)` |
| **Chaining** | `$('#list').append(item).addClass('loaded').show()` |
| **Event Delegation** | `$(document).on('click', '.delete-btn', fn)` |
| **Namespaced Events** | `$el.on('click.plugin', fn); $el.off('click.plugin')` |
| **AJAX** | `$.ajax({ url, method, data }).done(fn).fail(fn)` |
| **DOM Creation** | `$('<div>', { class: 'card', html: content })` |
| **Data Attributes** | `$el.data('userId', 123); const id = $el.data('userId')` |

## 3. Plugin Pattern

```javascript
(function($) {
  $.fn.tooltip = function(options) {
    return this.each(function() {
      $(this).on('mouseenter', showTooltip).on('mouseleave', hideTooltip);
    });
  };
})(jQuery);
```

## 4. Modern Alternative

```javascript
// Vanilla JS (preferred for new projects)
document.querySelectorAll('.item').forEach(el => el.classList.add('active'));

// vs jQuery
$('.item').addClass('active');
```

## AI Self-Check

- [ ] Selectors cached (stored in variables)?
- [ ] Event delegation for dynamic content?
- [ ] Methods chained when possible?
- [ ] Events namespaced?
- [ ] $.ajax() promises (not callbacks)?
- [ ] No repeated DOM queries?
- [ ] No $.each for arrays (using native forEach)?
- [ ] No document.write?
- [ ] No events bound to many elements (using delegation)?
- [ ] Considering vanilla JS/Alpine for new code?
- [ ] Performance optimized (selector caching)?
- [ ] Modern alternatives evaluated?


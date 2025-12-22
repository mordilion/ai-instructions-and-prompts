# WordPress Development

> **Scope**: Apply these rules when developing WordPress themes and plugins.

## Overview

WordPress is a PHP CMS powering 43% of websites. When developing plugins/themes, follow WordPress coding standards and security best practices.

**Key Capabilities**:
- **Hooks System**: Actions and filters for extensibility
- **Custom Post Types**: Extend content types
- **REST API**: Built-in API endpoints
- **Plugin/Theme Architecture**: Modular extensions
- **wpdb**: Database abstraction layer

## Best Practices

**MUST**:
- Check `ABSPATH` constant (security)
- Use `$wpdb->prepare()` for ALL SQL queries
- Verify nonces for form submissions
- Check user capabilities before sensitive operations
- Escape ALL output (esc_html, esc_url, esc_attr)

**SHOULD**:
- Use WordPress coding standards
- Prefix all functions/classes
- Use translation functions (__(), _e())
- Enqueue scripts/styles properly
- Use custom post types over custom tables

**AVOID**:
- Direct SQL without prepare (SQL injection!)
- Missing nonce checks (CSRF vulnerability)
- Missing capability checks (privilege escalation)
- Echoing unescaped user input (XSS)
- Global namespace pollution (use prefixes)

## 1. Plugin Structure
```
my-plugin/
├── my-plugin.php         # Main file with header
├── includes/
│   ├── class-plugin.php
│   └── class-admin.php
├── admin/                # Admin assets
├── public/               # Public assets
└── templates/
```

## 2. Plugin Header
```php
<?php
/**
 * Plugin Name: My Plugin
 * Version: 1.0.0
 * Requires PHP: 8.0
 */
if (!defined('ABSPATH')) exit;

define('MY_PLUGIN_PATH', plugin_dir_path(__FILE__));
require_once MY_PLUGIN_PATH . 'includes/class-plugin.php';
add_action('plugins_loaded', fn() => (new My_Plugin())->run());
```

## 3. Hooks
```php
// Actions (do something)
add_action('init', [$this, 'register_post_type']);
add_action('wp_ajax_my_action', [$this, 'handle_ajax']);
add_action('wp_ajax_nopriv_my_action', [$this, 'handle_ajax']);

// Filters (modify data)
add_filter('the_content', [$this, 'modify_content']);
```

## 4. Custom Post Types
```php
register_post_type('book', [
    'labels' => ['name' => __('Books', 'my-plugin'), 'singular_name' => __('Book', 'my-plugin')],
    'public' => true, 'has_archive' => true, 'show_in_rest' => true,
    'supports' => ['title', 'editor', 'thumbnail'],
]);
```

## 5. Database (wpdb)
```php
global $wpdb;

// Insert
$wpdb->insert($wpdb->prefix . 'my_table', ['col' => 'value'], ['%s']);

// Select (ALWAYS use prepare)
$results = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$wpdb->prefix}my_table WHERE status = %s", 'active'
));
```

## 6. Security
```php
// Nonce
wp_nonce_field('my_action', 'my_nonce');
if (!wp_verify_nonce($_POST['my_nonce'] ?? '', 'my_action')) wp_die('Security check failed');

// Capability
if (!current_user_can('manage_options')) wp_die('Unauthorized');

// Sanitize input
$title = sanitize_text_field($_POST['title']);
$email = sanitize_email($_POST['email']);

// Escape output
echo esc_html($title);
echo esc_url($url);
```

## 7. AJAX
```php
public function handle_ajax(): void {
    check_ajax_referer('my_nonce', 'nonce');
    if (!current_user_can('edit_posts')) wp_send_json_error(['message' => 'Unauthorized'], 403);
    wp_send_json_success(['data' => $result]);
}

// Localize script
wp_localize_script('my-script', 'myPlugin', ['ajaxUrl' => admin_url('admin-ajax.php'), 'nonce' => wp_create_nonce('my_nonce')]);
```

## 8. Best Practices
- **Prefix Everything**: Unique prefixes for functions, classes, hooks
- **Escape Late**: Escape just before output
- **Prepare SQL**: Always use `$wpdb->prepare()`
- **i18n**: Wrap strings in `__()` or `_e()`

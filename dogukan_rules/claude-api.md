---
globs: ["**/anthropic*", "**/claude-api*", "**/ai-service*"]
alwaysApply: false
---

# Claude API Integration Rules

<checklist>
## Before Writing API Code
- [ ] Check SDK version in package.json / requirements.txt
- [ ] Use environment variable for API key (`ANTHROPIC_API_KEY`)
- [ ] Plan error handling for rate limits (429) and overloaded (529)
- [ ] Consider streaming for long responses
- [ ] Estimate token usage and cost
</checklist>

<sdk-setup>
## SDK Setup

### TypeScript
```bash
npm install @anthropic-ai/sdk
```

```typescript
import Anthropic from '@anthropic-ai/sdk'

const client = new Anthropic()  // reads ANTHROPIC_API_KEY from env
```

### Python
```bash
pip install anthropic
```

```python
import anthropic

client = anthropic.Anthropic()  # reads ANTHROPIC_API_KEY from env
```

### Never hardcode API keys
```typescript
// BAD
const client = new Anthropic({ apiKey: "sk-ant-..." })

// GOOD
const client = new Anthropic()  // uses ANTHROPIC_API_KEY env var
```
</sdk-setup>

<messages-api>
## Messages API

### Basic Request
```typescript
const message = await client.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  system: "You are a helpful assistant.",
  messages: [
    { role: "user", content: "Hello, Claude!" }
  ]
})

console.log(message.content[0].text)
```

### Multi-Turn Conversation
```typescript
const messages = [
  { role: "user", content: "What is 2+2?" },
  { role: "assistant", content: "2+2 equals 4." },
  { role: "user", content: "And what is that times 3?" }
]

const response = await client.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  messages
})
```

### System Prompts
- Use `system` parameter (not a message with role "system")
- Keep system prompts focused and concise
- System prompt does not count toward `max_tokens` output limit
</messages-api>

<streaming>
## Streaming

### TypeScript
```typescript
const stream = client.messages.stream({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  messages: [{ role: "user", content: "Write a poem" }]
})

for await (const event of stream) {
  if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
    process.stdout.write(event.delta.text)
  }
}

const finalMessage = await stream.finalMessage()
```

### Python
```python
with client.messages.stream(
    model="claude-sonnet-4-6-20250514",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a poem"}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

### When to Stream
- Responses expected to be long (>500 tokens)
- User-facing applications where perceived latency matters
- Chat interfaces
</streaming>

<tool-use>
## Tool Use (Function Calling)

### Define Tools
```typescript
const tools = [
  {
    name: "get_weather",
    description: "Get current weather for a location",
    input_schema: {
      type: "object",
      properties: {
        location: { type: "string", description: "City name" }
      },
      required: ["location"]
    }
  }
]
```

### Handle Tool Use Round-Trip
```typescript
const response = await client.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  tools,
  messages: [{ role: "user", content: "What's the weather in Berlin?" }]
})

// Check if Claude wants to use a tool
if (response.stop_reason === "tool_use") {
  const toolUse = response.content.find(b => b.type === "tool_use")

  // Execute the tool
  const toolResult = await executeMyTool(toolUse.name, toolUse.input)

  // Send result back
  const finalResponse = await client.messages.create({
    model: "claude-sonnet-4-6-20250514",
    max_tokens: 1024,
    tools,
    messages: [
      { role: "user", content: "What's the weather in Berlin?" },
      { role: "assistant", content: response.content },
      {
        role: "user",
        content: [{
          type: "tool_result",
          tool_use_id: toolUse.id,
          content: JSON.stringify(toolResult)
        }]
      }
    ]
  })
}
```

### Content Block Types
- `text` — regular text response
- `tool_use` — Claude wants to call a tool (has `id`, `name`, `input`)
- `tool_result` — result you send back (references `tool_use_id`)
</tool-use>

<vision>
## Vision (Image Input)

### Base64
```typescript
const message = await client.messages.create({
  model: "claude-sonnet-4-6-20250514",
  max_tokens: 1024,
  messages: [{
    role: "user",
    content: [
      {
        type: "image",
        source: {
          type: "base64",
          media_type: "image/png",
          data: base64EncodedImage
        }
      },
      { type: "text", text: "Describe this image" }
    ]
  }]
})
```

### URL
```typescript
{
  type: "image",
  source: {
    type: "url",
    url: "https://example.com/image.png"
  }
}
```

### Supported Formats
- JPEG, PNG, GIF, WebP
- Max 5MB per image
- Multiple images supported in one message
</vision>

<error-handling>
## Error Handling

### Key Error Types
| Status | Error | Action |
|--------|-------|--------|
| 400 | Invalid request | Fix request format/params |
| 401 | Authentication error | Check API key |
| 429 | Rate limited | Retry with exponential backoff |
| 529 | Overloaded | Retry after delay (server busy) |
| 500 | Internal error | Retry, then report if persistent |

### Retry Pattern
```typescript
async function callWithRetry(fn: () => Promise<any>, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (error) {
      if (error instanceof Anthropic.RateLimitError) {
        const delay = Math.pow(2, i) * 1000
        await new Promise(r => setTimeout(r, delay))
        continue
      }
      if (error instanceof Anthropic.APIError && error.status === 529) {
        await new Promise(r => setTimeout(r, 5000))
        continue
      }
      throw error  // Non-retryable error
    }
  }
  throw new Error("Max retries exceeded")
}
```

### Context Length
- Check `error.type === "invalid_request_error"` with message about context length
- Reduce input tokens or use a model with larger context
- Use token counting to preemptively check
</error-handling>

<token-optimization>
## Token Counting & Cost

### Check Usage in Response
```typescript
const response = await client.messages.create({ ... })
console.log(response.usage)
// { input_tokens: 25, output_tokens: 150 }
```

### Cost Optimization
- Use `claude-haiku-4-5-20251001` for simple tasks (cheapest)
- Use `claude-sonnet-4-6-20250514` for standard tasks (best value)
- Use `claude-opus-4-6-20250514` only when deep reasoning is needed
- Keep system prompts concise — they count as input tokens
- Use `max_tokens` to limit output cost
- Cache repeated system prompts with prompt caching
</token-optimization>

<model-ids>
## Current Model IDs

| Model | ID | Best For |
|-------|-----|----------|
| Opus 4.6 | `claude-opus-4-6-20250514` | Complex reasoning, analysis |
| Sonnet 4.6 | `claude-sonnet-4-6-20250514` | General purpose, best value |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | Fast, simple tasks, cost-sensitive |
</model-ids>

<anti-patterns>
## Anti-Patterns
- Hardcoding API keys in source code
- Not handling 429/529 errors with retry logic
- Using Opus for simple tasks (cost waste)
- Ignoring `stop_reason` — missing tool use requests
- Sending tool results without the original `tool_use_id`
- Not checking `usage` for cost monitoring
- Blocking on long responses instead of streaming
</anti-patterns>

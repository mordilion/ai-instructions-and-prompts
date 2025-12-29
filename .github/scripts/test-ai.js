#!/usr/bin/env node

/**
 * AI Compatibility Test Runner
 * 
 * Tests AI models against standardized prompts to ensure consistent code quality
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Parse command line arguments
const args = process.argv.slice(2);
const model = args[args.indexOf('--model') + 1];
const provider = args[args.indexOf('--provider') + 1];
const testSuite = args[args.indexOf('--test-suite') + 1] || 'critical';

// Load test definitions
const testDefinitions = {
  'spring-boot': {
    id: 'test-1-spring-boot',
    name: 'Spring Boot Service',
    language: 'java',
    framework: 'spring-boot',
    prompt: `Create a Spring Boot service class that uses UserRepository to fetch a user by ID. The service should handle the case where the user is not found.`,
    expectedPatterns: [
      '@Service',
      '@RequiredArgsConstructor',
      '@Transactional(readOnly = true)',
      'private final UserRepository',
      'UserDto',
      'orElseThrow',
      'UserNotFoundException'
    ],
    forbiddenPatterns: [
      '@Autowired',
      'return.*User[^D]',  // Returns User not UserDto
      '\\.get\\(\\)'
    ],
    rules: [
      'rules/general/persona.md',
      'rules/general/architecture.md',
      'rules/general/code-style.md',
      'rules/java/architecture.md',
      'rules/java/code-style.md',
      'rules/java/frameworks/spring-boot.md'
    ]
  },
  
  'react': {
    id: 'test-2-react',
    name: 'React Component',
    language: 'typescript',
    framework: 'react',
    prompt: `Create a React component that fetches and displays a user by ID. The component should show a loading state while fetching and handle the case where the user is not found.`,
    expectedPatterns: [
      'const.*=.*React\\.FC',
      'useState',
      'useEffect',
      'userId.*\\]',  // userId in deps
      'if.*loading',
      'if.*!user'
    ],
    forbiddenPatterns: [
      'class.*extends.*Component',
      'useEffect.*\\[\\]',  // Empty deps when should have userId
      '^\\s*const\\s+[a-z]'  // camelCase component name
    ],
    rules: [
      'rules/general/persona.md',
      'rules/general/architecture.md',
      'rules/general/code-style.md',
      'rules/typescript/architecture.md',
      'rules/typescript/code-style.md',
      'rules/typescript/frameworks/react.md'
    ]
  },
  
  'aspnet': {
    id: 'test-3-aspnet',
    name: 'ASP.NET Core Controller',
    language: 'csharp',
    framework: 'aspnetcore',
    prompt: `Create an ASP.NET Core controller with a GET endpoint that fetches a user by ID. Return 404 if the user is not found.`,
    expectedPatterns: [
      '\\[ApiController\\]',
      '\\[HttpGet\\("{id}"\\)\\]',
      'ActionResult<UserDto>',
      'async Task',
      'await',
      'NotFound()',
      'private readonly.*Service'
    ],
    forbiddenPatterns: [
      'return.*User[^D]',  // Returns User not UserDto
      '\\[Autowired\\]',
      '_context\\.',  // Direct DB access
      'try.*catch'  // Try-catch in controller
    ],
    rules: [
      'rules/general/persona.md',
      'rules/general/architecture.md',
      'rules/general/code-style.md',
      'rules/dotnet/architecture.md',
      'rules/dotnet/code-style.md',
      'rules/dotnet/frameworks/aspnetcore.md'
    ]
  },
  
  'fastapi': {
    id: 'test-4-fastapi',
    name: 'FastAPI Endpoint',
    language: 'python',
    framework: 'fastapi',
    prompt: `Create a FastAPI endpoint that creates a new user. Validate the email format and return 201 Created status.`,
    expectedPatterns: [
      'class.*BaseModel',
      'EmailStr',
      '@app\\.post',
      'response_model=',
      'status_code=.*201',
      'async def'
    ],
    forbiddenPatterns: [
      '^def ',  // Sync def instead of async
      '@app\\.post.*\\)',  // Missing response_model
    ],
    rules: [
      'rules/general/persona.md',
      'rules/general/architecture.md',
      'rules/general/code-style.md',
      'rules/python/architecture.md',
      'rules/python/code-style.md',
      'rules/python/frameworks/fastapi.md'
    ]
  },
  
  'nextjs': {
    id: 'test-5-nextjs',
    name: 'Next.js Server Component',
    language: 'typescript',
    framework: 'nextjs',
    prompt: `Create a Next.js page that displays a list of users fetched from a database. Use the App Router and Server Components.`,
    expectedPatterns: [
      'async function',
      'await.*\\.findMany',
      'export default',
      'key={',
      '\\.map\\('
    ],
    forbiddenPatterns: [
      "'use client'",
      'useState',
      'useEffect'
    ],
    rules: [
      'rules/general/persona.md',
      'rules/general/architecture.md',
      'rules/general/code-style.md',
      'rules/typescript/architecture.md',
      'rules/typescript/code-style.md',
      'rules/typescript/frameworks/react.md',
      'rules/typescript/frameworks/nextjs.md'
    ]
  }
};

// Test suites
const testSuites = {
  critical: ['spring-boot', 'react', 'aspnet'],
  all: Object.keys(testDefinitions),
  'spring-boot': ['spring-boot'],
  'react': ['react'],
  'aspnet': ['aspnet'],
  'fastapi': ['fastapi'],
  'nextjs': ['nextjs']
};

// AI Provider clients
async function createAIClient(provider) {
  switch (provider) {
    case 'openai': {
      const { default: OpenAI } = await import('openai');
      return new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
    }
    
    case 'anthropic': {
      const { default: Anthropic } = await import('@anthropic-ai/sdk');
      return new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
    }
    
    case 'google': {
      const { GoogleGenerativeAI } = await import('@google/generative-ai');
      return new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
    }
    
    case 'mistral': {
      // Use OpenAI-compatible API
      const { default: OpenAI } = await import('openai');
      return new OpenAI({
        apiKey: process.env.MISTRAL_API_KEY,
        baseURL: 'https://api.mistral.ai/v1'
      });
    }
    
    case 'ollama': {
      // Local Ollama instance (free, no API key needed)
      const { default: OpenAI } = await import('openai');
      const baseURL = process.env.OLLAMA_BASE_URL || 'http://localhost:11434/v1';
      return new OpenAI({
        apiKey: 'ollama', // Ollama doesn't require real API key
        baseURL: baseURL
      });
    }
    
    case 'lmstudio': {
      // LM Studio local instance (free, no API key needed)
      const { default: OpenAI } = await import('openai');
      const baseURL = process.env.LMSTUDIO_BASE_URL || 'http://localhost:1234/v1';
      return new OpenAI({
        apiKey: 'lmstudio', // LM Studio doesn't require real API key
        baseURL: baseURL
      });
    }
    
    default:
      throw new Error(`Unknown provider: ${provider}`);
  }
}

// Load rule files
function loadRules(ruleFiles) {
  const rulesDir = path.join(process.cwd(), '.ai-iap');
  let rulesContent = '';
  
  for (const ruleFile of ruleFiles) {
    const filePath = path.join(rulesDir, ruleFile);
    if (fs.existsSync(filePath)) {
      rulesContent += fs.readFileSync(filePath, 'utf8') + '\n\n';
    } else {
      console.warn(`Warning: Rule file not found: ${ruleFile}`);
    }
  }
  
  return rulesContent;
}

// Call AI model
async function callAI(client, provider, model, systemPrompt, userPrompt) {
  try {
    switch (provider) {
      case 'openai':
      case 'mistral':
      case 'ollama':
      case 'lmstudio':
        const completion = await client.chat.completions.create({
          model: model,
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userPrompt }
          ],
          temperature: 0.3,
          max_tokens: 2000
        });
        return completion.choices[0].message.content;
      
      case 'anthropic':
        const message = await client.messages.create({
          model: model,
          max_tokens: 2000,
          temperature: 0.3,
          system: systemPrompt,
          messages: [
            { role: 'user', content: userPrompt }
          ]
        });
        return message.content[0].text;
      
      case 'google':
        const genModel = client.getGenerativeModel({ model: model });
        const result = await genModel.generateContent(
          `${systemPrompt}\n\n${userPrompt}`
        );
        return result.response.text();
      
      default:
        throw new Error(`Unknown provider: ${provider}`);
    }
  } catch (error) {
    console.error(`Error calling ${provider}:`, error.message);
    throw error;
  }
}

// Validate output against patterns
function validateOutput(output, test) {
  const results = {
    expectedMatches: [],
    expectedMissing: [],
    forbiddenFound: [],
    forbiddenMissing: []
  };
  
  // Check expected patterns
  for (const pattern of test.expectedPatterns) {
    const regex = new RegExp(pattern, 'gm');
    if (regex.test(output)) {
      results.expectedMatches.push(pattern);
    } else {
      results.expectedMissing.push(pattern);
    }
  }
  
  // Check forbidden patterns
  for (const pattern of test.forbiddenPatterns) {
    const regex = new RegExp(pattern, 'gm');
    if (regex.test(output)) {
      results.forbiddenFound.push(pattern);
    } else {
      results.forbiddenMissing.push(pattern);
    }
  }
  
  // Calculate score
  const expectedScore = (results.expectedMatches.length / test.expectedPatterns.length) * 70;
  const forbiddenScore = (results.forbiddenMissing.length / test.forbiddenPatterns.length) * 30;
  const totalScore = Math.round(expectedScore + forbiddenScore);
  
  return {
    score: totalScore,
    passed: totalScore >= 90,
    details: results
  };
}

// Run single test
async function runTest(client, provider, model, testKey) {
  const test = testDefinitions[testKey];
  console.log(`\nRunning test: ${test.name}`);
  
  const startTime = Date.now();
  
  try {
    // Load rules
    const rules = loadRules(test.rules);
    
    // Create system prompt
    const systemPrompt = `You are a senior software engineer. Follow these coding standards strictly:\n\n${rules}`;
    
    // Call AI
    const output = await callAI(client, provider, model, systemPrompt, test.prompt);
    
    // Validate output
    const validation = validateOutput(output, test);
    
    const duration = Date.now() - startTime;
    
    return {
      testId: test.id,
      testName: test.name,
      language: test.language,
      framework: test.framework,
      model: model,
      provider: provider,
      score: validation.score,
      passed: validation.passed,
      duration: duration,
      output: output,
      validation: validation.details,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    return {
      testId: test.id,
      testName: test.name,
      language: test.language,
      framework: test.framework,
      model: model,
      provider: provider,
      score: 0,
      passed: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
  }
}

// Main function
async function main() {
  console.log(`Testing ${model} (${provider}) with test suite: ${testSuite}`);
  
  // Create AI client
  const client = await createAIClient(provider);
  
  // Get tests to run
  const tests = testSuites[testSuite] || testSuites.critical;
  
  // Run tests
  const results = [];
  for (const testKey of tests) {
    const result = await runTest(client, provider, model, testKey);
    results.push(result);
    
    console.log(`  Score: ${result.score}/100 ${result.passed ? '✓' : '✗'}`);
  }
  
  // Calculate overall score
  const avgScore = Math.round(
    results.reduce((sum, r) => sum + r.score, 0) / results.length
  );
  const passRate = Math.round(
    (results.filter(r => r.passed).length / results.length) * 100
  );
  
  const summary = {
    model: model,
    provider: provider,
    testSuite: testSuite,
    totalTests: results.length,
    passed: results.filter(r => r.passed).length,
    failed: results.filter(r => !r.passed).length,
    averageScore: avgScore,
    passRate: passRate,
    tests: results,
    timestamp: new Date().toISOString()
  };
  
  // Save results
  const outputDir = path.join(process.cwd(), 'test-results');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  const outputFile = path.join(
    outputDir,
    `${provider}-${model.replace(/[^a-z0-9]/gi, '-')}-${Date.now()}.json`
  );
  fs.writeFileSync(outputFile, JSON.stringify(summary, null, 2));
  
  console.log(`\n=== Summary ===`);
  console.log(`Tests: ${summary.totalTests}`);
  console.log(`Passed: ${summary.passed}`);
  console.log(`Failed: ${summary.failed}`);
  console.log(`Average Score: ${summary.averageScore}/100`);
  console.log(`Pass Rate: ${summary.passRate}%`);
  console.log(`\nResults saved to: ${outputFile}`);
  
  // Exit with error if pass rate < 90%
  if (passRate < 90) {
    console.error(`\nERROR: Pass rate ${passRate}% is below threshold (90%)`);
    process.exit(1);
  }
}

main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});



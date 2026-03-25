#!/usr/bin/env node

/**
 * Claude Code Test Runner
 * 
 * Tests Claude against standardized prompts to ensure consistent code quality
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const args = process.argv.slice(2);
const testSuite = args[args.indexOf('--test-suite') + 1] || 'critical';

const model = 'claude-3-5-sonnet-20241022';

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
      'return.*User[^D]',
      '\\.get\\(\\)'
    ],
    rules: [
      '.ai-iap/rules/general/persona.md',
      '.ai-iap/rules/general/architecture.md',
      '.ai-iap/rules/general/code-style.md',
      '.ai-iap/rules/java/architecture.md',
      '.ai-iap/rules/java/code-style.md',
      '.ai-iap/rules/java/frameworks/spring-boot.md'
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
      'userId.*\\]',
      'if.*loading',
      'if.*!user'
    ],
    forbiddenPatterns: [
      'class.*extends.*Component',
      'useEffect.*\\[\\]',
      '^\\s*const\\s+[a-z]'
    ],
    rules: [
      '.ai-iap/rules/general/persona.md',
      '.ai-iap/rules/general/architecture.md',
      '.ai-iap/rules/general/code-style.md',
      '.ai-iap/rules/typescript/architecture.md',
      '.ai-iap/rules/typescript/code-style.md',
      '.ai-iap/rules/typescript/frameworks/react.md'
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
      'return.*User[^D]',
      '\\[Autowired\\]',
      '_context\\.',
      'try.*catch'
    ],
    rules: [
      '.ai-iap/rules/general/persona.md',
      '.ai-iap/rules/general/architecture.md',
      '.ai-iap/rules/general/code-style.md',
      '.ai-iap/rules/dotnet/architecture.md',
      '.ai-iap/rules/dotnet/code-style.md',
      '.ai-iap/rules/dotnet/frameworks/aspnetcore.md'
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
      '^def ',
      '@app\\.post.*\\)',
    ],
    rules: [
      '.ai-iap/rules/general/persona.md',
      '.ai-iap/rules/general/architecture.md',
      '.ai-iap/rules/general/code-style.md',
      '.ai-iap/rules/python/architecture.md',
      '.ai-iap/rules/python/code-style.md',
      '.ai-iap/rules/python/frameworks/fastapi.md'
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
      '.ai-iap/rules/general/persona.md',
      '.ai-iap/rules/general/architecture.md',
      '.ai-iap/rules/general/code-style.md',
      '.ai-iap/rules/typescript/architecture.md',
      '.ai-iap/rules/typescript/code-style.md',
      '.ai-iap/rules/typescript/frameworks/react.md',
      '.ai-iap/rules/typescript/frameworks/nextjs.md'
    ]
  }
};

const testSuites = {
  critical: ['spring-boot', 'react', 'aspnet'],
  all: Object.keys(testDefinitions),
  'spring-boot': ['spring-boot'],
  'react': ['react'],
  'aspnet': ['aspnet'],
  'fastapi': ['fastapi'],
  'nextjs': ['nextjs']
};

async function createClient() {
  const { default: Anthropic } = await import('@anthropic-ai/sdk');
  return new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
}

function loadRules(ruleFiles) {
  const projectRoot = path.join(__dirname, '..', '..');
  let rulesContent = '';
  
  for (const ruleFile of ruleFiles) {
    const filePath = path.join(projectRoot, ruleFile);
    if (fs.existsSync(filePath)) {
      rulesContent += fs.readFileSync(filePath, 'utf8') + '\n\n';
    } else {
      console.warn(`Warning: Rule file not found: ${ruleFile} (looking in ${filePath})`);
    }
  }
  
  return rulesContent;
}

async function callClaude(client, systemPrompt, userPrompt) {
  try {
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
  } catch (error) {
    console.error(`Error calling Claude:`, error.message);
    throw error;
  }
}

function validateOutput(output, test) {
  const results = {
    expectedMatches: [],
    expectedMissing: [],
    forbiddenFound: [],
    forbiddenMissing: []
  };
  
  for (const pattern of test.expectedPatterns) {
    const regex = new RegExp(pattern, 'gm');
    if (regex.test(output)) {
      results.expectedMatches.push(pattern);
    } else {
      results.expectedMissing.push(pattern);
    }
  }
  
  for (const pattern of test.forbiddenPatterns) {
    const regex = new RegExp(pattern, 'gm');
    if (regex.test(output)) {
      results.forbiddenFound.push(pattern);
    } else {
      results.forbiddenMissing.push(pattern);
    }
  }
  
  const expectedScore = (results.expectedMatches.length / test.expectedPatterns.length) * 70;
  const forbiddenScore = (results.forbiddenMissing.length / test.forbiddenPatterns.length) * 30;
  const totalScore = Math.round(expectedScore + forbiddenScore);
  
  return {
    score: totalScore,
    passed: totalScore >= 90,
    details: results
  };
}

async function runTest(client, testKey) {
  const test = testDefinitions[testKey];
  console.log(`\nRunning test: ${test.name}`);
  
  const startTime = Date.now();
  
  try {
    const rules = loadRules(test.rules);
    const systemPrompt = `You are a senior software engineer. Follow these coding standards strictly:\n\n${rules}`;
    const output = await callClaude(client, systemPrompt, test.prompt);
    const validation = validateOutput(output, test);
    const duration = Date.now() - startTime;
    
    return {
      testId: test.id,
      testName: test.name,
      language: test.language,
      framework: test.framework,
      model: model,
      provider: 'anthropic',
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
      provider: 'anthropic',
      score: 0,
      passed: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
  }
}

async function main() {
  console.log(`Testing Claude (${model}) with test suite: ${testSuite}`);
  
  const client = await createClient();
  const tests = testSuites[testSuite] || testSuites.critical;
  
  const results = [];
  for (const testKey of tests) {
    const result = await runTest(client, testKey);
    results.push(result);
    console.log(`  Score: ${result.score}/100 ${result.passed ? '✓' : '✗'}`);
  }
  
  const avgScore = Math.round(
    results.reduce((sum, r) => sum + r.score, 0) / results.length
  );
  const passRate = Math.round(
    (results.filter(r => r.passed).length / results.length) * 100
  );
  
  const summary = {
    model: model,
    provider: 'anthropic',
    testSuite: testSuite,
    totalTests: results.length,
    passed: results.filter(r => r.passed).length,
    failed: results.filter(r => !r.passed).length,
    averageScore: avgScore,
    passRate: passRate,
    tests: results,
    timestamp: new Date().toISOString()
  };
  
  const outputDir = path.join(process.cwd(), 'test-results');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  const outputFile = path.join(
    outputDir,
    `anthropic-${model.replace(/[^a-z0-9]/gi, '-')}-${Date.now()}.json`
  );
  fs.writeFileSync(outputFile, JSON.stringify(summary, null, 2));
  
  console.log(`\n=== Summary ===`);
  console.log(`Tests: ${summary.totalTests}`);
  console.log(`Passed: ${summary.passed}`);
  console.log(`Failed: ${summary.failed}`);
  console.log(`Average Score: ${summary.averageScore}/100`);
  console.log(`Pass Rate: ${summary.passRate}%`);
  console.log(`\nResults saved to: ${outputFile}`);
  
  if (passRate < 90) {
    console.error(`\nERROR: Pass rate ${passRate}% is below threshold (90%)`);
    process.exit(1);
  }
}

main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});

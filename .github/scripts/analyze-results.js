#!/usr/bin/env node

/**
 * Claude Code Results Analyzer
 * 
 * Analyzes test results from Claude to ensure rule quality
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const resultsDir = process.argv[2] || './all-results';

function loadResults(dir) {
  const results = [];
  
  if (!fs.existsSync(dir)) {
    console.error(`Results directory not found: ${dir}`);
    return results;
  }
  
  const entries = fs.readdirSync(dir);
  
  for (const entry of entries) {
    const entryPath = path.join(dir, entry);
    const stat = fs.statSync(entryPath);
    
    if (stat.isDirectory()) {
      const files = fs.readdirSync(entryPath).filter(f => f.endsWith('.json'));
      for (const file of files) {
        const filePath = path.join(entryPath, file);
        try {
          const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
          results.push(data);
        } catch (error) {
          console.error(`Error loading ${filePath}:`, error.message);
        }
      }
    } else if (entry.endsWith('.json')) {
      try {
        const data = JSON.parse(fs.readFileSync(entryPath, 'utf8'));
        results.push(data);
      } catch (error) {
        console.error(`Error loading ${entryPath}:`, error.message);
      }
    }
  }
  
  return results;
}

function analyzeResults(results) {
  if (results.length === 0) {
    return { error: 'No results to analyze' };
  }
  
  const testGroups = {};
  
  for (const result of results) {
    for (const test of result.tests) {
      if (!testGroups[test.testId]) {
        testGroups[test.testId] = [];
      }
      testGroups[test.testId].push({
        score: test.score,
        passed: test.passed,
        validation: test.validation
      });
    }
  }
  
  const testAnalysis = {};
  
  for (const [testId, testResults] of Object.entries(testGroups)) {
    const scores = testResults.map(r => r.score);
    const avgScore = scores.reduce((a, b) => a + b, 0) / scores.length;
    const passRate = (testResults.filter(r => r.passed).length / testResults.length) * 100;
    
    testAnalysis[testId] = {
      totalRuns: testResults.length,
      avgScore: Math.round(avgScore),
      passRate: Math.round(passRate),
      results: testResults
    };
  }
  
  const allScores = results.flatMap(r => r.tests.map(t => t.score));
  const overallAvg = Math.round(allScores.reduce((a, b) => a + b, 0) / allScores.length);
  
  return {
    overallAverage: overallAvg,
    totalTests: Object.keys(testGroups).length,
    totalRuns: results.length,
    testAnalysis,
    passing: overallAvg >= 90
  };
}

function generateReport(analysis) {
  let report = '# Claude Code Test Results\n\n';
  
  if (analysis.error) {
    report += `## Error\n\n${analysis.error}\n`;
    return report;
  }
  
  report += '## Summary\n\n';
  report += `- **Overall Average Score**: ${analysis.overallAverage}/100\n`;
  report += `- **Total Tests**: ${analysis.totalTests}\n`;
  report += `- **Total Runs**: ${analysis.totalRuns}\n`;
  report += `- **Status**: ${analysis.passing ? '✅ PASS' : '⚠️ NEEDS ATTENTION'}\n`;
  report += '\n';
  
  report += '## Test-by-Test Analysis\n\n';
  
  for (const [testId, test] of Object.entries(analysis.testAnalysis)) {
    const passIcon = test.passRate === 100 ? '✅' : test.passRate >= 80 ? '⚠️' : '❌';
    
    report += `### ${passIcon} ${testId}\n\n`;
    report += `- **Average Score**: ${test.avgScore}/100\n`;
    report += `- **Pass Rate**: ${test.passRate}%\n`;
    report += '\n';
  }
  
  report += '## Recommendations\n\n';
  
  if (analysis.passing) {
    report += '✅ **All tests passing!** Rules are producing high-quality code with Claude.\n\n';
  } else {
    report += '⚠️ **Action items**:\n\n';
    
    const failingTests = Object.entries(analysis.testAnalysis)
      .filter(([_, test]) => test.passRate < 100)
      .map(([id, _]) => id);
    
    if (failingTests.length > 0) {
      report += `1. **Improve rules** for failing tests: ${failingTests.join(', ')}\n`;
      report += '   - Add more explicit `> **ALWAYS**` / `> **NEVER**` directives\n';
      report += '   - Strengthen pattern descriptions in rules\n';
      report += '   - Add more code examples with correct/incorrect patterns\n\n';
    }
    
    if (analysis.overallAverage < 90) {
      report += '2. **Improve overall scores**:\n';
      report += '   - Review failed pattern matches in test results\n';
      report += '   - Ensure rules are clear and unambiguous\n';
      report += '   - Add AI Self-Check sections to catch common mistakes\n\n';
    }
  }
  
  report += '## Success Criteria\n\n';
  report += 'Rules should produce consistent, high-quality code:\n';
  report += '- ✅ Consistent code structure and architecture patterns\n';
  report += '- ✅ Same security practices applied (OWASP Top 10, input validation)\n';
  report += '- ✅ Same testing approaches (unit, integration, mocking)\n';
  report += '- ✅ Same CI/CD best practices (version detection, caching)\n\n';
  
  const criteriaCheck = analysis.passing;
  report += '**Current Status**: ';
  report += criteriaCheck 
    ? '✅ **MEETING CRITERIA**\n'
    : '⚠️ **NOT YET MEETING CRITERIA** - See recommendations above\n';
  
  return report;
}

function main() {
  console.log('Loading test results...');
  const results = loadResults(resultsDir);
  
  console.log(`Found ${results.length} result files`);
  
  if (results.length === 0) {
    console.log('No results to analyze. This is expected if no tests ran (e.g., missing API key).');
    const report = generateReport({ error: 'No results found. Tests may not have run.' });
    fs.writeFileSync('analysis-report.md', report);
    process.exit(0);
  }
  
  console.log('Analyzing results...');
  const analysis = analyzeResults(results);
  
  console.log('Generating report...');
  const report = generateReport(analysis);
  
  fs.writeFileSync('analysis-report.md', report);
  console.log('Report saved to analysis-report.md');
  
  console.log('\n=== Summary ===');
  console.log(`Overall Average: ${analysis.overallAverage}/100`);
  console.log(`Status: ${analysis.passing ? 'PASS' : 'FAIL'}`);
  
  if (!analysis.passing) {
    console.error('\nERROR: Not meeting success criteria');
    process.exit(1);
  }
}

main();

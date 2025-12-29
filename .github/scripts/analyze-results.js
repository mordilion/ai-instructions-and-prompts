#!/usr/bin/env node

/**
 * AI Compatibility Results Analyzer
 * 
 * Compares test results across multiple AI models to ensure consistency
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Parse command line arguments
const resultsDir = process.argv[2] || './all-results';

// Load all result files
function loadResults(dir) {
  const results = [];
  
  if (!fs.existsSync(dir)) {
    console.error(`Results directory not found: ${dir}`);
    return results;
  }
  
  const providers = fs.readdirSync(dir);
  
  for (const provider of providers) {
    const providerDir = path.join(dir, provider);
    
    if (!fs.statSync(providerDir).isDirectory()) {
      continue;
    }
    
    const files = fs.readdirSync(providerDir).filter(f => f.endsWith('.json'));
    
    for (const file of files) {
      const filePath = path.join(providerDir, file);
      try {
        const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        results.push(data);
      } catch (error) {
        console.error(`Error loading ${filePath}:`, error.message);
      }
    }
  }
  
  return results;
}

// Analyze consistency across AIs
function analyzeConsistency(results) {
  if (results.length === 0) {
    return {
      error: 'No results to analyze'
    };
  }
  
  // Group by test ID
  const testGroups = {};
  
  for (const result of results) {
    for (const test of result.tests) {
      if (!testGroups[test.testId]) {
        testGroups[test.testId] = [];
      }
      testGroups[test.testId].push({
        model: result.model,
        provider: result.provider,
        score: test.score,
        passed: test.passed,
        validation: test.validation
      });
    }
  }
  
  // Analyze each test
  const testAnalysis = {};
  
  for (const [testId, testResults] of Object.entries(testGroups)) {
    const scores = testResults.map(r => r.score);
    const avgScore = scores.reduce((a, b) => a + b, 0) / scores.length;
    const minScore = Math.min(...scores);
    const maxScore = Math.max(...scores);
    const variance = maxScore - minScore;
    const passRate = (testResults.filter(r => r.passed).length / testResults.length) * 100;
    
    testAnalysis[testId] = {
      testName: testResults[0].testName || testId,
      totalRuns: testResults.length,
      avgScore: Math.round(avgScore),
      minScore,
      maxScore,
      variance,
      passRate: Math.round(passRate),
      consistent: variance <= 10,  // Variance threshold
      results: testResults
    };
  }
  
  // Overall analysis
  const allScores = results.flatMap(r => r.tests.map(t => t.score));
  const overallAvg = Math.round(allScores.reduce((a, b) => a + b, 0) / allScores.length);
  
  const modelScores = {};
  for (const result of results) {
    const key = `${result.provider}/${result.model}`;
    if (!modelScores[key]) {
      modelScores[key] = [];
    }
    modelScores[key].push(...result.tests.map(t => t.score));
  }
  
  const modelAverages = {};
  for (const [model, scores] of Object.entries(modelScores)) {
    modelAverages[model] = Math.round(scores.reduce((a, b) => a + b, 0) / scores.length);
  }
  
  return {
    overallAverage: overallAvg,
    totalTests: Object.keys(testGroups).length,
    totalRuns: results.length,
    modelAverages,
    testAnalysis,
    consistent: Object.values(testAnalysis).every(t => t.consistent)
  };
}

// Generate markdown report
function generateReport(analysis) {
  let report = '# AI Compatibility Test Results\n\n';
  
  if (analysis.error) {
    report += `## ❌ Error\n\n${analysis.error}\n`;
    return report;
  }
  
  // Overall summary
  report += '## 📊 Overall Summary\n\n';
  report += `- **Overall Average Score**: ${analysis.overallAverage}/100\n`;
  report += `- **Total Tests**: ${analysis.totalTests}\n`;
  report += `- **Total Runs**: ${analysis.totalRuns}\n`;
  report += `- **Cross-AI Consistency**: ${analysis.consistent ? '✅ PASS' : '⚠️ NEEDS ATTENTION'}\n`;
  report += '\n';
  
  // Model comparison
  report += '## 🤖 Model Performance\n\n';
  report += '| Model | Average Score | Status |\n';
  report += '|-------|---------------|--------|\n';
  
  for (const [model, score] of Object.entries(analysis.modelAverages)) {
    const status = score >= 90 ? '✅ PASS' : score >= 80 ? '⚠️ WARNING' : '❌ FAIL';
    report += `| ${model} | ${score}/100 | ${status} |\n`;
  }
  report += '\n';
  
  // Test-by-test analysis
  report += '## 📝 Test-by-Test Analysis\n\n';
  
  for (const [testId, test] of Object.entries(analysis.testAnalysis)) {
    const icon = test.consistent ? '✅' : '⚠️';
    const passIcon = test.passRate === 100 ? '✅' : test.passRate >= 80 ? '⚠️' : '❌';
    
    report += `### ${icon} ${test.testName}\n\n`;
    report += `- **Average Score**: ${test.avgScore}/100\n`;
    report += `- **Score Range**: ${test.minScore} - ${test.maxScore} (variance: ${test.variance})\n`;
    report += `- **Pass Rate**: ${passIcon} ${test.passRate}%\n`;
    report += `- **Consistency**: ${test.consistent ? 'GOOD (≤10% variance)' : 'NEEDS IMPROVEMENT (>10% variance)'}\n`;
    report += '\n';
    
    // Model-by-model breakdown
    report += '**Per-Model Results**:\n\n';
    report += '| Provider | Model | Score | Status |\n';
    report += '|----------|-------|-------|--------|\n';
    
    for (const result of test.results) {
      const status = result.passed ? '✅ PASS' : '❌ FAIL';
      report += `| ${result.provider} | ${result.model} | ${result.score}/100 | ${status} |\n`;
    }
    report += '\n';
  }
  
  // Recommendations
  report += '## 💡 Recommendations\n\n';
  
  if (analysis.consistent && analysis.overallAverage >= 90) {
    report += '✅ **All systems green!** Your rules are producing consistent, high-quality code across all tested AIs.\n\n';
  } else {
    report += '⚠️ **Action items**:\n\n';
    
    if (!analysis.consistent) {
      const inconsistentTests = Object.entries(analysis.testAnalysis)
        .filter(([_, test]) => !test.consistent)
        .map(([_, test]) => test.testName);
      
      report += `1. **Improve consistency** for: ${inconsistentTests.join(', ')}\n`;
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
    
    // Identify worst-performing model
    const worstModel = Object.entries(analysis.modelAverages)
      .sort(([, a], [, b]) => a - b)[0];
    
    if (worstModel && worstModel[1] < 90) {
      report += `3. **Focus on ${worstModel[0]}** (lowest score: ${worstModel[1]}/100):\n`;
      report += '   - Test specific prompts with this model manually\n';
      report += '   - Adjust phrasing if this model interprets differently\n\n';
    }
  }
  
  // Success criteria
  report += '## 🎯 Success Criteria (from `.cursor/rules/general.mdc`)\n\n';
  report += 'Your goal: "Same Result" across all AIs means:\n';
  report += '- ✅ Consistent code structure and architecture patterns\n';
  report += '- ✅ Same security practices applied (OWASP Top 10, input validation)\n';
  report += '- ✅ Same testing approaches (unit, integration, mocking)\n';
  report += '- ✅ Same CI/CD best practices (version detection, caching)\n';
  report += '- ℹ️ Not byte-for-byte identical, but architecturally equivalent\n\n';
  
  report += '**Current Status**:\n';
  const criteriaCheck = analysis.consistent && analysis.overallAverage >= 92;
  report += criteriaCheck 
    ? '✅ **MEETING CRITERIA** - Cross-AI consistency achieved\n'
    : '⚠️ **NOT YET MEETING CRITERIA** - See recommendations above\n';
  
  return report;
}

// Main function
function main() {
  console.log('Loading test results...');
  const results = loadResults(resultsDir);
  
  console.log(`Found ${results.length} result files`);
  
  if (results.length === 0) {
    console.log('No results to analyze. This is expected if no tests ran (e.g., missing API keys).');
    const report = generateReport({ error: 'No results found. Tests may not have run.' });
    fs.writeFileSync('analysis-report.md', report);
    process.exit(0);
  }
  
  console.log('Analyzing consistency...');
  const analysis = analyzeConsistency(results);
  
  console.log('Generating report...');
  const report = generateReport(analysis);
  
  // Save report
  fs.writeFileSync('analysis-report.md', report);
  console.log('Report saved to analysis-report.md');
  
  // Print summary
  console.log('\n=== Summary ===');
  console.log(`Overall Average: ${analysis.overallAverage}/100`);
  console.log(`Consistency: ${analysis.consistent ? 'PASS' : 'FAIL'}`);
  
  // Exit with error if not meeting criteria
  if (!analysis.consistent || analysis.overallAverage < 90) {
    console.error('\nERROR: Not meeting success criteria');
    process.exit(1);
  }
}

main();


#!/usr/bin/env python3
"""
Analyze AI test results and generate summary
"""

import json
import glob
import os
import sys
from pathlib import Path
from datetime import datetime
from collections import defaultdict

def load_results(results_dir):
    """Load all test result JSON files"""
    results = []
    pattern = os.path.join(results_dir, '**/*.json')
    
    for filepath in glob.glob(pattern, recursive=True):
        try:
            with open(filepath, 'r') as f:
                data = json.load(f)
                results.append(data)
        except json.JSONDecodeError:
            print(f"Warning: Could not parse {filepath}", file=sys.stderr)
        except Exception as e:
            print(f"Warning: Error loading {filepath}: {e}", file=sys.stderr)
    
    return results

def calculate_stats(results):
    """Calculate statistics across all results"""
    if not results:
        return {}
    
    stats = {
        'by_model': defaultdict(lambda: {
            'total_tests': 0,
            'passed': 0,
            'failed': 0,
            'scores': [],
            'pass_rates': []
        }),
        'by_test': defaultdict(lambda: {
            'models': [],
            'scores': [],
            'passed_count': 0,
            'failed_count': 0
        }),
        'overall': {
            'total_results': len(results),
            'models_tested': set(),
            'average_score': 0,
            'average_pass_rate': 0
        }
    }
    
    total_score = 0
    total_pass_rate = 0
    
    for result in results:
        model = result.get('model', 'unknown')
        stats['overall']['models_tested'].add(model)
        
        # Model stats
        model_stats = stats['by_model'][model]
        model_stats['total_tests'] += result.get('totalTests', 0)
        model_stats['passed'] += result.get('passed', 0)
        model_stats['failed'] += result.get('failed', 0)
        model_stats['scores'].append(result.get('averageScore', 0))
        model_stats['pass_rates'].append(result.get('passRate', 0))
        
        total_score += result.get('averageScore', 0)
        total_pass_rate += result.get('passRate', 0)
        
        # Test-level stats
        for test in result.get('tests', []):
            test_id = test.get('testId', 'unknown')
            test_stats = stats['by_test'][test_id]
            test_stats['models'].append(model)
            test_stats['scores'].append(test.get('score', 0))
            if test.get('passed', False):
                test_stats['passed_count'] += 1
            else:
                test_stats['failed_count'] += 1
    
    # Calculate averages
    stats['overall']['average_score'] = round(total_score / len(results)) if results else 0
    stats['overall']['average_pass_rate'] = round(total_pass_rate / len(results)) if results else 0
    stats['overall']['models_tested'] = sorted(list(stats['overall']['models_tested']))
    
    return stats

def generate_summary_markdown(stats, output_file):
    """Generate markdown summary report"""
    
    md = []
    md.append("# AI Compatibility Test Results")
    md.append("")
    md.append(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    md.append("")
    
    # Overall stats
    md.append("## Overall Summary")
    md.append("")
    md.append(f"- **Models Tested**: {', '.join(stats['overall']['models_tested'])}")
    md.append(f"- **Total Test Runs**: {stats['overall']['total_results']}")
    md.append(f"- **Average Score**: {stats['overall']['average_score']}/100")
    md.append(f"- **Average Pass Rate**: {stats['overall']['average_pass_rate']}%")
    md.append("")
    
    # Status indicator
    if stats['overall']['average_pass_rate'] >= 95:
        md.append("✅ **Status**: EXCELLENT - All AI models producing consistent high-quality code")
    elif stats['overall']['average_pass_rate'] >= 85:
        md.append("⚠️  **Status**: GOOD - Most AI models producing quality code, minor improvements needed")
    elif stats['overall']['average_pass_rate'] >= 75:
        md.append("⚠️  **Status**: FAIR - Significant quality gaps between AI models")
    else:
        md.append("❌ **Status**: POOR - Major quality inconsistencies across AI models")
    md.append("")
    
    # By model
    md.append("## Results by AI Model")
    md.append("")
    md.append("| Model | Tests | Passed | Failed | Avg Score | Pass Rate | Status |")
    md.append("|-------|-------|--------|--------|-----------|-----------|--------|")
    
    for model, model_stats in sorted(stats['by_model'].items()):
        avg_score = round(sum(model_stats['scores']) / len(model_stats['scores'])) if model_stats['scores'] else 0
        avg_pass_rate = round(sum(model_stats['pass_rates']) / len(model_stats['pass_rates'])) if model_stats['pass_rates'] else 0
        
        status = "✅" if avg_pass_rate >= 95 else "⚠️" if avg_pass_rate >= 85 else "❌"
        
        md.append(f"| {model} | {model_stats['total_tests']} | {model_stats['passed']} | {model_stats['failed']} | {avg_score}/100 | {avg_pass_rate}% | {status} |")
    
    md.append("")
    
    # By test
    md.append("## Results by Test")
    md.append("")
    md.append("| Test | Models Tested | Passed | Failed | Avg Score | Consistency |")
    md.append("|------|---------------|--------|--------|-----------|-------------|")
    
    for test_id, test_stats in sorted(stats['by_test'].items()):
        models_count = len(set(test_stats['models']))
        avg_score = round(sum(test_stats['scores']) / len(test_stats['scores'])) if test_stats['scores'] else 0
        
        # Calculate consistency (lower std dev = more consistent)
        if len(test_stats['scores']) > 1:
            mean = sum(test_stats['scores']) / len(test_stats['scores'])
            variance = sum((x - mean) ** 2 for x in test_stats['scores']) / len(test_stats['scores'])
            std_dev = variance ** 0.5
            consistency = "✅ High" if std_dev < 10 else "⚠️ Medium" if std_dev < 20 else "❌ Low"
        else:
            consistency = "N/A"
        
        md.append(f"| {test_id} | {models_count} | {test_stats['passed_count']} | {test_stats['failed_count']} | {avg_score}/100 | {consistency} |")
    
    md.append("")
    
    # Recommendations
    md.append("## Recommendations")
    md.append("")
    
    if stats['overall']['average_pass_rate'] < 95:
        md.append("### Immediate Actions Required")
        md.append("")
        
        # Find models below threshold
        low_performing = []
        for model, model_stats in stats['by_model'].items():
            avg_pass_rate = round(sum(model_stats['pass_rates']) / len(model_stats['pass_rates'])) if model_stats['pass_rates'] else 0
            if avg_pass_rate < 90:
                low_performing.append((model, avg_pass_rate))
        
        if low_performing:
            md.append("**Models needing improvement:**")
            for model, pass_rate in sorted(low_performing, key=lambda x: x[1]):
                md.append(f"- **{model}**: {pass_rate}% pass rate (target: 95%)")
            md.append("")
            md.append("**Recommended fixes:**")
            md.append("1. Review `PRIORITY_ACTIONS.md` for improvement strategies")
            md.append("2. Add more explicit ALWAYS/NEVER directives to affected framework files")
            md.append("3. Include more 'Common AI Mistakes' examples")
            md.append("4. Re-run tests after applying fixes")
        
        # Find tests with high failure rates
        problematic_tests = []
        for test_id, test_stats in stats['by_test'].items():
            failure_rate = (test_stats['failed_count'] / (test_stats['passed_count'] + test_stats['failed_count'])) * 100
            if failure_rate > 20:
                problematic_tests.append((test_id, failure_rate))
        
        if problematic_tests:
            md.append("")
            md.append("**Tests with high failure rates:**")
            for test_id, failure_rate in sorted(problematic_tests, key=lambda x: -x[1]):
                md.append(f"- **{test_id}**: {round(failure_rate)}% failure rate")
            md.append("")
            md.append("Review these test scenarios and strengthen related rule files.")
    else:
        md.append("✅ All AI models performing excellently! No immediate actions required.")
        md.append("")
        md.append("**Maintenance:**")
        md.append("- Continue monitoring daily test runs")
        md.append("- Review any new failures promptly")
        md.append("- Keep rule files updated with new patterns")
    
    md.append("")
    md.append("---")
    md.append("*For detailed results, check individual test artifacts.*")
    
    # Write to file
    with open(output_file, 'w') as f:
        f.write('\n'.join(md))
    
    print(f"Summary written to {output_file}")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Analyze AI test results')
    parser.add_argument('--results-dir', required=True, help='Directory containing test results')
    parser.add_argument('--output', required=True, help='Output markdown file')
    
    args = parser.parse_args()
    
    # Load results
    print(f"Loading results from {args.results_dir}...")
    results = load_results(args.results_dir)
    print(f"Loaded {len(results)} result files")
    
    if not results:
        print("ERROR: No results found", file=sys.stderr)
        sys.exit(1)
    
    # Calculate stats
    print("Calculating statistics...")
    stats = calculate_stats(results)
    
    # Generate summary
    print("Generating summary...")
    generate_summary_markdown(stats, args.output)
    
    print("Done!")

if __name__ == '__main__':
    main()



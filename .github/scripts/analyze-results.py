#!/usr/bin/env python3
"""
Analyze Claude test results and generate summary
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
        'by_test': defaultdict(lambda: {
            'scores': [],
            'passed_count': 0,
            'failed_count': 0
        }),
        'overall': {
            'total_results': len(results),
            'average_score': 0,
            'average_pass_rate': 0
        }
    }
    
    total_score = 0
    total_pass_rate = 0
    
    for result in results:
        total_score += result.get('averageScore', 0)
        total_pass_rate += result.get('passRate', 0)
        
        for test in result.get('tests', []):
            test_id = test.get('testId', 'unknown')
            test_stats = stats['by_test'][test_id]
            test_stats['scores'].append(test.get('score', 0))
            if test.get('passed', False):
                test_stats['passed_count'] += 1
            else:
                test_stats['failed_count'] += 1
    
    stats['overall']['average_score'] = round(total_score / len(results)) if results else 0
    stats['overall']['average_pass_rate'] = round(total_pass_rate / len(results)) if results else 0
    
    return stats

def generate_summary_markdown(stats, output_file):
    """Generate markdown summary report"""
    
    md = []
    md.append("# Claude Code Test Results")
    md.append("")
    md.append(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    md.append("")
    
    md.append("## Overall Summary")
    md.append("")
    md.append(f"- **Total Test Runs**: {stats['overall']['total_results']}")
    md.append(f"- **Average Score**: {stats['overall']['average_score']}/100")
    md.append(f"- **Average Pass Rate**: {stats['overall']['average_pass_rate']}%")
    md.append("")
    
    if stats['overall']['average_pass_rate'] >= 95:
        md.append("✅ **Status**: EXCELLENT - Producing consistent high-quality code")
    elif stats['overall']['average_pass_rate'] >= 85:
        md.append("⚠️  **Status**: GOOD - Minor improvements needed")
    elif stats['overall']['average_pass_rate'] >= 75:
        md.append("⚠️  **Status**: FAIR - Significant quality gaps")
    else:
        md.append("❌ **Status**: POOR - Major quality issues")
    md.append("")
    
    md.append("## Results by Test")
    md.append("")
    md.append("| Test | Passed | Failed | Avg Score |")
    md.append("|------|--------|--------|-----------|")
    
    for test_id, test_stats in sorted(stats['by_test'].items()):
        avg_score = round(sum(test_stats['scores']) / len(test_stats['scores'])) if test_stats['scores'] else 0
        md.append(f"| {test_id} | {test_stats['passed_count']} | {test_stats['failed_count']} | {avg_score}/100 |")
    
    md.append("")
    
    md.append("## Recommendations")
    md.append("")
    
    if stats['overall']['average_pass_rate'] < 95:
        md.append("### Actions Required")
        md.append("")
        
        problematic_tests = []
        for test_id, test_stats in stats['by_test'].items():
            total = test_stats['passed_count'] + test_stats['failed_count']
            failure_rate = (test_stats['failed_count'] / total) * 100 if total > 0 else 0
            if failure_rate > 20:
                problematic_tests.append((test_id, failure_rate))
        
        if problematic_tests:
            md.append("**Tests with high failure rates:**")
            for test_id, failure_rate in sorted(problematic_tests, key=lambda x: -x[1]):
                md.append(f"- **{test_id}**: {round(failure_rate)}% failure rate")
            md.append("")
            md.append("Review these test scenarios and strengthen related rule files.")
        
        md.append("")
        md.append("**Recommended fixes:**")
        md.append("1. Add more explicit ALWAYS/NEVER directives to affected framework files")
        md.append("2. Include more 'Common AI Mistakes' examples")
        md.append("3. Re-run tests after applying fixes")
    else:
        md.append("✅ All tests performing excellently! No immediate actions required.")
        md.append("")
        md.append("**Maintenance:**")
        md.append("- Continue monitoring test runs")
        md.append("- Review any new failures promptly")
        md.append("- Keep rule files updated with new patterns")
    
    md.append("")
    md.append("---")
    md.append("*For detailed results, check individual test artifacts.*")
    
    with open(output_file, 'w') as f:
        f.write('\n'.join(md))
    
    print(f"Summary written to {output_file}")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Analyze Claude test results')
    parser.add_argument('--results-dir', required=True, help='Directory containing test results')
    parser.add_argument('--output', required=True, help='Output markdown file')
    
    args = parser.parse_args()
    
    print(f"Loading results from {args.results_dir}...")
    results = load_results(args.results_dir)
    print(f"Loaded {len(results)} result files")
    
    if not results:
        print("ERROR: No results found", file=sys.stderr)
        sys.exit(1)
    
    print("Calculating statistics...")
    stats = calculate_stats(results)
    
    print("Generating summary...")
    generate_summary_markdown(stats, args.output)
    
    print("Done!")

if __name__ == '__main__':
    main()

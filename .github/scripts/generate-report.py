#!/usr/bin/env python3
"""
Generate detailed comparison report across AI models
"""

import json
import glob
import os
import sys
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
        except Exception:
            continue
    
    return results

def generate_comparison_report(results, output_file):
    """Generate detailed comparison markdown"""
    
    # Group by test
    by_test = defaultdict(list)
    for result in results:
        for test in result.get('tests', []):
            by_test[test['testId']].append({
                'model': result['model'],
                'score': test.get('score', 0),
                'passed': test.get('passed', False),
                'output': test.get('output', ''),
                'validation': test.get('validation', {})
            })
    
    md = []
    md.append("# Detailed AI Comparison Report")
    md.append("")
    
    for test_id in sorted(by_test.keys()):
        test_results = by_test[test_id]
        md.append(f"## {test_id}")
        md.append("")
        
        # Summary table
        md.append("| Model | Score | Status | Expected Patterns | Forbidden Patterns |")
        md.append("|-------|-------|--------|-------------------|-------------------|")
        
        for tr in sorted(test_results, key=lambda x: -x['score']):
            status = "✅ PASS" if tr['passed'] else "❌ FAIL"
            validation = tr.get('validation', {})
            
            expected_match = len(validation.get('expectedMatches', []))
            expected_missing = len(validation.get('expectedMissing', []))
            forbidden_found = len(validation.get('forbiddenFound', []))
            forbidden_missing = len(validation.get('forbiddenMissing', []))
            
            expected_str = f"{expected_match} ✓, {expected_missing} ✗"
            forbidden_str = f"{forbidden_missing} ✓, {forbidden_found} ✗"
            
            md.append(f"| {tr['model']} | {tr['score']}/100 | {status} | {expected_str} | {forbidden_str} |")
        
        md.append("")
        
        # Show issues if any
        issues_found = False
        for tr in test_results:
            validation = tr.get('validation', {})
            expected_missing = validation.get('expectedMissing', [])
            forbidden_found = validation.get('forbiddenFound', [])
            
            if expected_missing or forbidden_found:
                if not issues_found:
                    md.append("### Issues Found")
                    md.append("")
                    issues_found = True
                
                md.append(f"**{tr['model']}:**")
                if expected_missing:
                    md.append(f"- Missing expected patterns: `{', '.join(expected_missing)}`")
                if forbidden_found:
                    md.append(f"- Found forbidden patterns: `{', '.join(forbidden_found)}`")
                md.append("")
        
        if not issues_found:
            md.append("✅ All models passed this test successfully!")
            md.append("")
        
        md.append("---")
        md.append("")
    
    # Write report
    with open(output_file, 'w') as f:
        f.write('\n'.join(md))
    
    print(f"Comparison report written to {output_file}")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate comparison report')
    parser.add_argument('--results-dir', required=True)
    parser.add_argument('--output', required=True)
    
    args = parser.parse_args()
    
    results = load_results(args.results_dir)
    if not results:
        print("ERROR: No results found", file=sys.stderr)
        sys.exit(1)
    
    generate_comparison_report(results, args.output)

if __name__ == '__main__':
    main()



#!/usr/bin/env python3
"""
Check if test results meet minimum quality thresholds
"""

import json
import glob
import os
import sys

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

def check_thresholds(results, min_score):
    """Check if results meet minimum thresholds"""
    
    failures = []
    
    for result in results:
        model = result.get('model', 'unknown')
        avg_score = result.get('averageScore', 0)
        pass_rate = result.get('passRate', 0)
        
        if avg_score < min_score:
            failures.append({
                'model': model,
                'type': 'score',
                'value': avg_score,
                'threshold': min_score,
                'message': f"{model} average score {avg_score}/100 is below threshold {min_score}/100"
            })
        
        if pass_rate < min_score:
            failures.append({
                'model': model,
                'type': 'pass_rate',
                'value': pass_rate,
                'threshold': min_score,
                'message': f"{model} pass rate {pass_rate}% is below threshold {min_score}%"
            })
    
    return failures

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Check quality thresholds')
    parser.add_argument('--results-dir', required=True)
    parser.add_argument('--min-score', type=int, default=90, 
                       help='Minimum score/pass rate required')
    
    args = parser.parse_args()
    
    print(f"Checking thresholds (minimum: {args.min_score})...")
    
    results = load_results(args.results_dir)
    if not results:
        print("WARNING: No results found to check", file=sys.stderr)
        sys.exit(0)
    
    failures = check_thresholds(results, args.min_score)
    
    if failures:
        print(f"\n❌ THRESHOLD CHECK FAILED ({len(failures)} issues found):")
        print("")
        for failure in failures:
            print(f"  • {failure['message']}")
        print("")
        print("Action required:")
        print("  1. Review PRIORITY_ACTIONS.md for improvement strategies")
        print("  2. Update affected rule files with more explicit directives")
        print("  3. Re-run tests to verify improvements")
        print("")
        sys.exit(1)
    else:
        print(f"\n✅ ALL THRESHOLDS MET")
        print(f"   All AI models scored above {args.min_score}")
        sys.exit(0)

if __name__ == '__main__':
    main()



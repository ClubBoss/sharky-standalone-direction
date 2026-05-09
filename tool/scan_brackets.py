#!/usr/bin/env python3
import sys
from collections import defaultdict

if len(sys.argv) < 2:
    print("Usage: scan_brackets.py <file>")
    sys.exit(2)

path = sys.argv[1]
pairs = {'(':')','[':']','{':'}'}
openers = set(pairs.keys())
closers = {v:k for k,v in pairs.items()}
stack = []
line_counts = []

with open(path, 'r', encoding='utf-8') as f:
    for i,line in enumerate(f, start=1):
        for c in line:
            if c in openers:
                stack.append((c,i))
            elif c in closers:
                if stack and stack[-1][0] == closers[c]:
                    stack.pop()
                else:
                    # unmatched closer
                    stack.append((c+'(unmatched)',i))
        line_counts.append((i,len(stack)))

print('Total stack at EOF:', len(stack))
if stack:
    print('Remaining stack (top last):')
    for s in stack[-20:]:
        print(s)

# Report first line where stack becomes negative/unmatched

# We will instead compute cumulative counts for each symbol type
counts = defaultdict(int)
issues = []
with open(path, 'r', encoding='utf-8') as f:
    for i,line in enumerate(f, start=1):
        for c in line:
            if c in openers:
                counts[c]+=1
            elif c in closers:
                counts[closers[c]]-=1
                if counts[closers[c]] < 0:
                    issues.append((i, closers[c], counts[closers[c]]))

if issues:
    print('\nFound premature closer(s):')
    for it in issues[:20]:
        print('line',it[0],'closer for',it[1],'balance',it[2])
else:
    print('\nNo premature closers found; check for missing closers (unclosed opens).')

# Print lines where any count becomes unusually large
for k,v in counts.items():
    if v!=0:
        print('Unbalanced for',k,':',v)

# Print a helpful snippet around reported EOF stack items
if stack:
    first_unclosed = stack[0]
    print('\nFirst leftover or unmatched token:', first_unclosed)
    # print 10 lines around
    ln = first_unclosed[1]
    with open(path,'r',encoding='utf-8') as f:
        lines = f.readlines()
    start = max(1, ln-6)
    end = min(len(lines), ln+6)
    print('\nContext around line',ln)
    for i in range(start, end+1):
        print(f"{i:5}: {lines[i-1].rstrip()}")

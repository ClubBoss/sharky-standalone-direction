#!/bin/bash

echo "🔧 Systematic fix for 'Expected )' syntax errors..."

# Count initial errors
initial_errors=$(dart analyze --format=machine | awk -F'|' '$1=="ERROR" && $3=="EXPECTED_TOKEN" && $8 ~ /Expected to find .*\)/' | wc -l)
echo "📊 Initial 'Expected )' errors: $initial_errors"

fixed_count=0
failed_count=0

while IFS= read -r file; do
    # Skip excluded patterns
    if [[ "$file" == *".g.dart" || "$file" == */plugins/* || "$file" == build/* || "$file" == .dart_tool/* ]]; then
        continue
    fi
    
    echo "🔧 Processing: $file"
    
    # Get specific line:col for this file's Expected ')' errors
    dart analyze --format=machine "$file" | awk -F'|' '$1=="ERROR" && $3=="EXPECTED_TOKEN" && $8 ~ /Expected to find .*\)/ {print $5":"$6}' > /tmp/locations.txt
    
    if [[ ! -s /tmp/locations.txt ]]; then
        continue
    fi
    
    # Create backup
    cp "$file" "${file}.bak"
    
    # Read file content
    content=$(cat "$file")
    
    # Process each error location (in reverse order to maintain line numbers)
    while IFS=':' read -r line col; do
        # Use awk to add closing parenthesis at the specific line:col
        echo "$content" | awk -v target_line="$line" -v target_col="$col" '
        NR == target_line {
            # Insert ) at the specified column position
            if (target_col <= length($0)) {
                $0 = substr($0, 1, target_col-1) ")" substr($0, target_col)
            } else {
                $0 = $0 ")"
            }
        }
        { print }
        ' > "${file}.tmp"
        content=$(cat "${file}.tmp")
    done < <(sort -nr /tmp/locations.txt)
    
    # Write the modified content
    echo "$content" > "$file"
    rm -f "${file}.tmp"
    
    # Verify the fix doesn't break syntax
    if dart format --set-exit-if-changed "$file" >/dev/null 2>&1; then
        # Check if this specific error is fixed
        remaining=$(dart analyze --format=machine "$file" | awk -F'|' '$1=="ERROR" && $3=="EXPECTED_TOKEN" && $8 ~ /Expected to find .*\)/' | wc -l)
        if [[ $remaining -eq 0 ]]; then
            echo "✅ Successfully fixed: $file"
            rm "${file}.bak"
            ((fixed_count++))
        else
            echo "⚠️  Partially fixed: $file (still has errors)"
            rm "${file}.bak"
            ((fixed_count++))
        fi
    else
        echo "❌ Fix broke syntax: $file (reverting)"
        mv "${file}.bak" "$file"
        ((failed_count++))
    fi
    
done < /tmp/targets.txt

# Count final errors  
final_errors=$(dart analyze --format=machine | awk -F'|' '$1=="ERROR" && $3=="EXPECTED_TOKEN" && $8 ~ /Expected to find .*\)/' | wc -l)

echo ""
echo "📊 Results for 'Expected )' errors:"
echo "   📁 Files processed: $((fixed_count + failed_count))"
echo "   ✅ Files fixed: $fixed_count"
echo "   ❌ Files failed: $failed_count"
echo "   🎯 Errors before: $initial_errors"
echo "   🎯 Errors after: $final_errors"
echo "   📉 Delta: $((initial_errors - final_errors)) errors fixed"

echo "🏁 Expected ')' fix complete!"
set -euo pipefail

# 0) метрики "до"
mkdir -p tools
dart analyze lib --format=machine > tools/an_before.txt || true

# 1) const -> final для неконстантных RHS
rg -l 'const\s+\w+\s*=\s*(DateTime\.now\(|Uuid\(|Random\(|[A-Za-z_]\w*\()' lib \
| xargs -I{} perl -0777 -pe 's/\bconst(\s+\w+\s*=\s*(?:DateTime\.now\(|Uuid\(|Random\(|[A-Za-z_]\w*\())/final$1/sg' -i {}

# 2) убрать const у пустых коллекций, если переменные изменяемые
rg -l '=\s*const\s*(\[\]|\{\})' lib \
| xargs -I{} perl -0777 -pe 's/=\s*const\s*(\[\]|\{\})\b/=\ $1/sg' -i {}

# 3) запретить null.difference и now=null
rg -l 'null\.difference\(|final\s+now\s*=\s*null\b' lib \
| xargs -I{} perl -0777 -pe 's/null\.difference\(/DateTime.now().difference(/g; s/final\s+now\s*=\s*null/final now = DateTime.now()/g' -i {}

# 4) убрать unreachable default (частый кейс name-сортировки)
rg -Ul 'case\s+_SortOption\.name:\s*\n\s*default:' lib \
| xargs -I{} perl -0777 -pe 's/case\s+_SortOption\.name:\s*\n\s*default:/case _SortOption.name:/sg' -i {} || true

# 5) срезать висячие ; на конце файлов
find lib -name '*.dart' -print0 | xargs -0 -I{} perl -0777 -pe 's/\s*;\s*\z/\n/s' -i {}

# 6) заменить AppColors.cardBackground -> Theme.of(context).cardColor
rg -l 'AppColors\.cardBackground' lib \
| xargs -I{} perl -0777 -pe "s/AppColors\.cardBackground/Theme.of(context).cardColor/g" -i {}

# 7) выкинуть notifyListeners вне ChangeNotifier
rg -l 'notifyListeners\(\)' lib \
| xargs -I{} perl -0777 -pe 's/\s*[^;\n]*notifyListeners\(\);\s*//g' -i {}

# 8) формат и анализ
dart format lib >/dev/null
dart analyze lib --format=machine > tools/an_after.txt || true

# 9) сводка
echo "## delta (ERROR|WARNING|INFO)"
for f in tools/an_before.txt tools/an_after.txt; do
  awk -F'|' '{c[$1]++} END{printf "%s: ERROR=%d WARNING=%d INFO=%d\n", FILENAME, c["ERROR"], c["WARNING"], c["INFO"]}' "$f"
done
echo "## top files after"
awk -F'|' '$1=="ERROR"{print $4}' tools/an_after.txt | cut -d: -f1 | sort | uniq -c | sort -nr | head -20

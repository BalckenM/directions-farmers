import os

cwd = os.getcwd()
path = os.path.join(cwd, 'lib', 'features', 'poultry', 'screens', 'flock_detail_screen.dart')
with open(path, encoding='utf-8') as f:
    lines = f.readlines()

print(f'Total lines: {len(lines)}')

# Line 447 (0-indexed) is the corruption prefix merged with line 1 of original
# Line 448 (0-indexed: 447) starts the clean embedded copy
# First corruption marker is at line 2727 (1-indexed) = index 2726

# Original line 1 is 'import package:csv/csv.dart;'
line1 = "import 'package:csv/csv.dart';\n"

# Lines 2+ of original are at indices 447-2725 (lines 448-2726)
restored = [line1] + lines[447:2726]
print(f'Restored lines: {len(restored)}')
print('Line 1:', repr(restored[0]))
print('Line 448 (last):', repr(restored[-1]))

# Check last line doesn't have corruption
if 'Groups[1].Value' in restored[-1] or 'alpha = [double]' in restored[-1]:
    print('ERROR: Last line is corrupted!')
else:
    print('Last line looks clean')

# Check line 447 in corrupted (should be the import partial)
print('Line 447 in corrupted:', repr(lines[446]))
print('Line 448 in corrupted:', repr(lines[447]))

# Write restored file
out_path = path
with open(out_path, 'w', encoding='utf-8') as f:
    f.writelines(restored)
print(f'Written {len(restored)} lines to {out_path}')

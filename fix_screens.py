import os

cwd = os.getcwd()
base = os.path.join(cwd, 'lib', 'features', 'poultry', 'screens')

# Fix poultry_screen.dart
# Find all marker positions to determine embedded copy boundaries
path = os.path.join(base, 'poultry_screen.dart')
with open(path, encoding='utf-8') as f:
    lines = f.readlines()

markers = [i+1 for i, l in enumerate(lines) if 'Groups[1].Value' in l]
print(f'poultry_screen.dart: {len(lines)} lines, {len(markers)} markers at {markers}')

# Find the 'alpha = [double]' lines that start each embedded copy
alpha_lines = [(i+1, lines[i].rstrip()) for i, l in enumerate(lines) if 'alpha = [double]' in l]
print(f'Alpha markers: {len(alpha_lines)}')
for a in alpha_lines[:5]:
    print(f'  Line {a[0]}: {repr(a[1][:80])}')

# The original file starts after first occurrence of the corruption prefix
# Find first line that looks like it has import at position after alpha prefix
first_import_idx = None
for i, line in enumerate(lines):
    if 'alpha = [double]' in line and 'import ' in line:
        first_import_idx = i
        print(f'First import corruption line {i+1}: {repr(line.rstrip()[:100])}')
        print(f'Next line {i+2}: {repr(lines[i+1].rstrip()[:100])}')
        break

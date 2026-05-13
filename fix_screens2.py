import os

cwd = os.getcwd()
base = os.path.join(cwd, 'lib', 'features', 'poultry', 'screens')

# Fix add_disease_event_screen.dart
# alpha at line 99, clean copy starts at 100, first marker at 510
# so clean copy is lines 100-509 (0-indexed 99-508)
path = os.path.join(base, 'add_disease_event_screen.dart')
with open(path, encoding='utf-8') as f:
    lines = f.readlines()

line1 = "import 'package:flutter/material.dart';\n"
restored = [line1] + lines[99:509]
print(f'Restored {len(restored)} lines')
print('Line 1:', repr(restored[0]))
print('Last:', repr(restored[-1]))

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(restored)
print('Written add_disease_event_screen.dart!')

# Fix poultry_screen.dart
# First alpha at line 280, clean copy at 281, next alpha at 1457
# clean copy is lines 281-1456 (0-indexed 280-1455)
path2 = os.path.join(base, 'poultry_screen.dart')
with open(path2, encoding='utf-8') as f:
    lines2 = f.readlines()

line1b = "import 'package:dio/dio.dart';\n"
restored2 = [line1b] + lines2[280:1456]
print(f'Restored {len(restored2)} lines for poultry_screen.dart')
print('Line 1:', repr(restored2[0]))
print('Last:', repr(restored2[-1]))

with open(path2, 'w', encoding='utf-8') as f:
    f.writelines(restored2)
print('Written poultry_screen.dart!')

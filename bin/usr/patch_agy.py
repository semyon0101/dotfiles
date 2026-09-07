#!/usr/bin/env python
path = '/home/semyon/.local/bin/agy'
with open(path, 'rb') as f:
    data = f.read()

target = b'ineligible'
replacement = b'inexigible'

count = data.count(target)
if count == 0:
    print('Pattern ineligible not found or already patched.')
else:
    patched = data.replace(target, replacement)
    with open(path, 'wb') as f:
        f.write(patched)
    print(f'Successfully patched {count} occurrence(s).')


import os
import glob

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace withDefaultData
    content = content.replace('InMemoryShoppingListRemoteDataSource()', 'InMemoryShoppingListRemoteDataSource.withDefaultData()')
    
    # We shouldn't replace it everywhere blindly (e.g. if the test genuinely wants empty).
    # Let's just do it in the files where it was previously withDefaultData()
    # Actually, we can just change it. The original code used it where it needed.
    # We can just change all of them, or let's be careful.
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

# only specific files that failed:
files = [
    'test/features/shopping_list/shopping_list_sections_test.dart',
    'test/features/shopping_list/shopping_mode_test.dart',
    'test/features/shopping_list/presentation/views/shopping_list_view_test.dart',
]

for filepath in files:
    if os.path.exists(filepath):
        process_file(filepath)

print("Done")

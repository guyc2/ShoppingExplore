import os

files = [
    'test/features/shopping_list/shopping_list_crud_test.dart',
    'test/features/shopping_list/shopping_list_realtime_sync_test.dart',
    'test/features/shopping_list/share_shopping_list_test.dart'
]

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content.replace('InMemoryShoppingListRemoteDataSource.withDefaultData()', 'InMemoryShoppingListRemoteDataSource()')
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

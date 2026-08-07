import os
import glob

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'InMemoryShoppingListLocalDataSource' not in content and 'localDataSource' not in content:
        return

    # Replace import
    content = content.replace(
        "import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_local_datasource.dart';",
        "import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';\nimport 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';\nimport 'package:mockito/mockito.dart';"
    )

    # Replace class Fake definition if not exists
    if 'FakeStorageRepository' not in content:
        # insert after imports
        import_end = content.rfind("import '")
        if import_end != -1:
            end_of_line = content.find('\n', import_end)
            content = content[:end_of_line+1] + "\nclass FakeStorageRepository extends Fake implements StorageRepository {}\n" + content[end_of_line+1:]

    # Replace class name
    content = content.replace('InMemoryShoppingListLocalDataSource', 'InMemoryShoppingListRemoteDataSource')

    # Replace withDefaultData
    content = content.replace('InMemoryShoppingListRemoteDataSource.withDefaultData()', 'InMemoryShoppingListRemoteDataSource()')

    # Replace variable names
    content = content.replace('localDataSource: localDataSource', 'remoteDataSource: localDataSource,\n        storageRepository: FakeStorageRepository()')
    content = content.replace('localDataSource: dataSource', 'remoteDataSource: dataSource,\n        storageRepository: FakeStorageRepository()')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

search_path = 'test/features/shopping_list/**/*.dart'
for filepath in glob.glob(search_path, recursive=True):
    process_file(filepath)

print("Done")

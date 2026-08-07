import 'dart:io';

void main() {
  var file = File('test/features/auth/auth_mocks.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r'\s*returnValue:\s*[^,]+,'), '');
  file.writeAsStringSync(content);
}

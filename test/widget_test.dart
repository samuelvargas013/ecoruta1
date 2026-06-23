import 'package:flutter_test/flutter_test.dart';

import 'package:ecoruta1/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email válido pasa', () {
      expect(Validators.email('ana@example.com'), isNull);
    });
    test('email inválido falla', () {
      expect(Validators.email('correo-malo'), isNotNull);
    });
    test('contraseña corta falla', () {
      expect(Validators.password('123'), isNotNull);
    });
    test('contraseña válida pasa', () {
      expect(Validators.password('secreta1'), isNull);
    });
  });
}

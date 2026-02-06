import 'package:test/test.dart';
import 'package:veegify/services/auth_service.dart';

void main() {
  group('AuthService – basic tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('AuthService instance should be created', () {
      expect(authService, isNotNull);
    });

    test('Login throws error on invalid input', () async {
      expect(
        () async => await authService.login(
          phoneNumber: '',
          password: '',
        ),
        throwsA(anything),
      );
    });
  });
}

import 'package:test/test.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';

void main() {
  group('AuthProvider - initial state', () {
    test('should have no user initially', () {
      final provider = AuthProvider();

      expect(provider.currentUser, isNull);
    });

    test('should not be loading initially', () {
      final provider = AuthProvider();

      expect(provider.isLoading, isFalse);
    });

    test('should have no error initially', () {
      final provider = AuthProvider();

      expect(provider.errorMessage, isNull);
    });

    test('should have no token initially', () {
      final provider = AuthProvider();

      expect(provider.token, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// UNIT TEST EXAMPLES
// These demonstrate testing pure business logic
// =============================================================================

void main() {
  group('Calculator', () {
    late Calculator calculator;

    setUp(() {
      calculator = Calculator();
    });

    test('adds two numbers correctly', () {
      expect(calculator.add(2, 3), equals(5));
      expect(calculator.add(-1, 1), equals(0));
      expect(calculator.add(0, 0), equals(0));
    });

    test('multiplies two numbers correctly', () {
      expect(calculator.multiply(2, 3), equals(6));
      expect(calculator.multiply(-2, 3), equals(-6));
      expect(calculator.multiply(0, 5), equals(0));
    });

    test('divides two numbers correctly', () {
      expect(calculator.divide(6, 2), equals(3.0));
      expect(calculator.divide(5, 2), equals(2.5));
    });

    test('returns null when dividing by zero', () {
      expect(calculator.divide(5, 0), isNull);
    });
  });

  group('UserValidator', () {
    test('validates email format', () {
      expect(UserValidator.isValidEmail('test@example.com'), isTrue);
      expect(UserValidator.isValidEmail('invalid.email'), isFalse);
      expect(UserValidator.isValidEmail(''), isFalse);
    });

    test('validates password strength', () {
      expect(UserValidator.isStrongPassword('Abcd1234!'), isTrue);
      expect(UserValidator.isStrongPassword('weak'), isFalse);
      expect(UserValidator.isStrongPassword('12345678'), isFalse);
    });
  });
}

// =============================================================================
// CLASSES UNDER TEST
// =============================================================================

class Calculator {
  int add(int a, int b) => a + b;
  int multiply(int a, int b) => a * b;
  double? divide(int a, int b) {
    if (b == 0) return null;
    return a / b;
  }
}

class UserValidator {
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    return hasUppercase && hasLowercase && hasDigit;
  }
}

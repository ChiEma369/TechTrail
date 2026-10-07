import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techtrail_mobile/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('Singleton instance should be identical', () {
      final instance1 = AuthService.instance;
      final instance2 = AuthService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('Initial getters should be null or false when not logged in', () {
      final authService = AuthService.instance;
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentSession, isNull);
      expect(authService.currentUser, isNull);
      expect(authService.currentUserId, isNull);
      expect(authService.currentUserEmail, isNull);
      expect(authService.currentUserFullName, isNull);
    });

    group('Error message localization to Vietnamese', () {
      test('Parses invalid login credentials', () {
        final error = const AuthException('Invalid login credentials');
        final message = AuthService.getErrorMessage(error);
        expect(message, 'Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.');
      });

      test('Parses already registered user', () {
        final error = const AuthException('User already registered');
        final message = AuthService.getErrorMessage(error);
        expect(message, 'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.');
      });

      test('Parses weak password', () {
        final error = const AuthException('Password should be at least 6 characters');
        final message = AuthService.getErrorMessage(error);
        expect(message, 'Mật khẩu phải chứa ít nhất 6 ký tự.');
      });

      test('Parses email not confirmed', () {
        final error = const AuthException('Email not confirmed');
        final message = AuthService.getErrorMessage(error);
        expect(message, 'Tài khoản chưa được xác thực email. Vui lòng kiểm tra hộp thư của bạn.');
      });

      test('Parses rate limit error', () {
        final error = const AuthException('over_request_rate_limit');
        final message = AuthService.getErrorMessage(error);
        expect(message, 'Bạn đã thao tác quá nhiều lần. Vui lòng đợi ít phút trước khi thử lại.');
      });

      test('Parses socket exception (no internet)', () {
        const error = SocketException('Failed host lookup');
        final message = AuthService.getErrorMessage(error);
        expect(message, 'Không thể kết nối Internet. Vui lòng kiểm tra lại mạng Wi-Fi hoặc 4G/5G.');
      });
    });
  });
}

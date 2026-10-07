import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service quản lý toàn bộ các tác vụ Xác thực (Authentication)
/// và Phiên đăng nhập (Session) dùng chung cho cả ứng dụng.
class AuthService {
  AuthService._internal();

  /// Singleton instance dùng chung
  static final AuthService instance = AuthService._internal();

  factory AuthService() => instance;

  // ==========================================
  // GETTERS THÔNG TIN PHIÊN & NGƯỜI DÙNG
  // ==========================================

  /// Lấy session đăng nhập hiện tại
  Session? get currentSession {
    if (!SupabaseService.isInitialized) return null;
    return SupabaseService.auth.currentSession;
  }

  /// Lấy thông tin user hiện tại
  User? get currentUser {
    if (!SupabaseService.isInitialized) return null;
    return SupabaseService.auth.currentUser;
  }

  /// Kiểm tra xem người dùng đã đăng nhập và có session hợp lệ chưa
  bool get isAuthenticated => currentSession != null;

  /// Lấy User ID của người dùng hiện tại
  String? get currentUserId => currentUser?.id;

  /// Lấy email người dùng hiện tại
  String? get currentUserEmail => currentUser?.email;

  /// Lấy họ tên hiển thị của người dùng (từ metadata)
  String? get currentUserFullName {
    final metadata = currentUser?.userMetadata;
    if (metadata == null) return null;
    return metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        currentUserEmail?.split('@').first;
  }

  /// Lấy avatar url (nếu có)
  String? get currentUserAvatarUrl {
    final metadata = currentUser?.userMetadata;
    return metadata?['avatar_url'] as String?;
  }

  // ==========================================
  // STREAMS THEO DÕI TRẠNG THÁI REAL-TIME
  // ==========================================

  /// Lắng nghe mọi thay đổi về phiên đăng nhập (login, logout, refresh, update)
  Stream<AuthState> get onAuthStateChange {
    if (!SupabaseService.isInitialized) {
      return const Stream.empty();
    }
    return SupabaseService.auth.onAuthStateChange;
  }

  /// Lắng nghe sự thay đổi của User
  Stream<User?> get onUserChange {
    return onAuthStateChange.map((authState) => authState.session?.user);
  }

  /// Lắng nghe trạng thái đăng nhập (true: đã đăng nhập, false: chưa)
  Stream<bool> get onAuthStatusChange {
    return onAuthStateChange.map((authState) => authState.session != null);
  }

  // ==========================================
  // CÁC HÀM XÁC THỰC CHÍNH (AUTH METHODS)
  // ==========================================

  /// Đăng ký tài khoản mới bằng Email và Mật khẩu
  ///
  /// [email]: Email của tài khoản
  /// [password]: Mật khẩu (tối thiểu 6 ký tự)
  /// [fullName]: Họ và tên hiển thị
  /// [data]: Metadata bổ sung tùy chỉnh
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    Map<String, dynamic>? data,
  }) async {
    _ensureInitialized();
    try {
      final userMetadata = <String, dynamic>{
        if (fullName != null && fullName.trim().isNotEmpty)
          'full_name': fullName.trim(),
        ...?data,
      };

      final response = await SupabaseService.auth.signUp(
        email: email.trim(),
        password: password,
        data: userMetadata.isNotEmpty ? userMetadata : null,
      );
      debugPrint('[AuthService] Đăng ký thành công cho email: $email');
      return response;
    } catch (e) {
      debugPrint('[AuthService] Lỗi signUp: $e');
      rethrow;
    }
  }

  /// Đăng nhập bằng Email và Mật khẩu
  ///
  /// [email]: Email tài khoản
  /// [password]: Mật khẩu
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _ensureInitialized();
    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AuthService] Đăng nhập thành công: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('[AuthService] Lỗi signIn: $e');
      rethrow;
    }
  }

  /// Đăng xuất khỏi hệ thống và xóa session cục bộ
  Future<void> signOut() async {
    _ensureInitialized();
    try {
      await SupabaseService.auth.signOut();
      debugPrint('[AuthService] Đã đăng xuất thành công.');
    } catch (e) {
      debugPrint('[AuthService] Lỗi signOut: $e');
      rethrow;
    }
  }

  /// Gửi email khôi phục mật khẩu
  Future<void> resetPassword(String email, {String? redirectTo}) async {
    _ensureInitialized();
    try {
      await SupabaseService.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectTo,
      );
      debugPrint('[AuthService] Đã gửi email reset mật khẩu tới: $email');
    } catch (e) {
      debugPrint('[AuthService] Lỗi resetPassword: $e');
      rethrow;
    }
  }

  /// Cập nhật mật khẩu mới cho người dùng hiện tại
  Future<UserResponse> updatePassword(String newPassword) async {
    _ensureInitialized();
    try {
      final response = await SupabaseService.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      debugPrint('[AuthService] Đổi mật khẩu thành công.');
      return response;
    } catch (e) {
      debugPrint('[AuthService] Lỗi updatePassword: $e');
      rethrow;
    }
  }

  /// Cập nhật thông tin profile của người dùng
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? data,
  }) async {
    _ensureInitialized();
    try {
      final currentMeta =
          Map<String, dynamic>.from(currentUser?.userMetadata ?? {});
      if (fullName != null) currentMeta['full_name'] = fullName.trim();
      if (avatarUrl != null) currentMeta['avatar_url'] = avatarUrl.trim();
      if (data != null) currentMeta.addAll(data);

      final response = await SupabaseService.auth.updateUser(
        UserAttributes(data: currentMeta),
      );
      debugPrint('[AuthService] Cập nhật thông tin profile thành công.');
      return response;
    } catch (e) {
      debugPrint('[AuthService] Lỗi updateProfile: $e');
      rethrow;
    }
  }

  /// Làm mới phiên đăng nhập (refresh token)
  Future<Session?> refreshSession() async {
    _ensureInitialized();
    try {
      final response = await SupabaseService.auth.refreshSession();
      debugPrint('[AuthService] Đã làm mới session token thành công.');
      return response.session;
    } catch (e) {
      debugPrint('[AuthService] Lỗi refreshSession: $e');
      return null;
    }
  }

  // ==========================================
  // XỬ LÝ LỖI CHUẨN HÓA TIẾNG VIỆT
  // ==========================================

  /// Chuyển đổi mã lỗi sang thông báo thân thiện với người dùng
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      final statusCode = error.statusCode;

      if (message.contains('invalid login credentials') ||
          message.contains('invalid credential') ||
          statusCode == '400' && message.contains('grant')) {
        return 'Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.';
      }
      if (message.contains('user already registered') ||
          message.contains('already exists')) {
        return 'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.';
      }
      if (message.contains('password should be at least') ||
          message.contains('weak password')) {
        return 'Mật khẩu phải chứa ít nhất 6 ký tự.';
      }
      if (message.contains('email not confirmed')) {
        return 'Tài khoản chưa được xác thực email. Vui lòng kiểm tra hộp thư của bạn.';
      }
      if (message.contains('over_request_rate_limit') ||
          message.contains('rate limit')) {
        return 'Bạn đã thao tác quá nhiều lần. Vui lòng đợi ít phút trước khi thử lại.';
      }
      if (message.contains('invalid email') ||
          message.contains('unable to validate email')) {
        return 'Địa chỉ email không hợp lệ. Vui lòng kiểm tra lại cú pháp email.';
      }
      return error.message;
    }

    if (error is SocketException) {
      return 'Không thể kết nối Internet. Vui lòng kiểm tra lại mạng Wi-Fi hoặc 4G/5G.';
    }

    if (error is StateError) {
      return error.message;
    }

    return 'Đã xảy ra sự cố: ${error.toString()}';
  }

  void _ensureInitialized() {
    if (!SupabaseService.isInitialized) {
      throw StateError(
        'Supabase chưa được cấu hình. Vui lòng cập nhật URL và AnonKey trong lib/config/supabase_config.dart',
      );
    }
  }
}

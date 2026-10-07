import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service quản lý vòng đời và kết nối của Supabase trong toàn bộ ứng dụng
class SupabaseService {
  static bool _isInitialized = false;

  /// Trạng thái đã khởi tạo Supabase hay chưa
  static bool get isInitialized => _isInitialized;

  /// Khởi tạo Supabase client an toàn
  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint(
        '[SupabaseService] CHÚ Ý: SupabaseConfig đang dùng key mẫu. '
        'Vui lòng cập nhật URL và anonKey trong lib/config/supabase_config.dart để kết nối DB.',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Khởi tạo Supabase thành công.');
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi khi khởi tạo Supabase: $e');
    }
  }

  /// Truy cập SupabaseClient dùng chung cho toàn bộ app
  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'Supabase chưa được khởi tạo thành công! '
        'Vui lòng điền đúng URL và AnonKey trong lib/config/supabase_config.dart',
      );
    }
    return Supabase.instance.client;
  }

  /// Truy cập GoTrueClient (Authentication)
  static GoTrueClient get auth => client.auth;
}

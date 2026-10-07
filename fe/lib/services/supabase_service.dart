import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[SupabaseService] SupabaseConfig chưa được cấu hình đầy đủ.');
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

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'Supabase chưa được khởi tạo thành công! '
        'Vui lòng kiểm tra lib/config/supabase_config.dart',
      );
    }
    return Supabase.instance.client;
  }

  static GoTrueClient get auth => client.auth;
}

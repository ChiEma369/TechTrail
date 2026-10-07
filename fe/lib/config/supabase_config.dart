class SupabaseConfig {
  // Thay thế bằng URL và Anon Key thực tế từ Supabase Dashboard của bạn:
  // https://supabase.com/dashboard/project/<your-project-id>/settings/api
  static const String url = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';

  /// Kiểm tra xem cấu hình đã được điền thông tin thật hay vẫn là placeholder mẫu
  static bool get isConfigured {
    return url.isNotEmpty &&
        !url.contains('YOUR_PROJECT_REF') &&
        anonKey.isNotEmpty &&
        anonKey != 'YOUR_ANON_KEY';
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

/// Widget AuthGate tự động điều hướng màn hình dựa trên phiên đăng nhập (Session)
/// Dùng chung làm Root screen cho toàn bộ ứng dụng TechTrail.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isCheckingInitial = true;

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    // Đợi một khoảng ngắn để Supabase phục hồi session đã lưu trong bộ nhớ cục bộ
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isCheckingInitial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trường hợp 1: Chưa cấu hình Supabase URL & Anon Key thực tế
    if (!SupabaseService.isInitialized) {
      return _buildConfigurationPromptScreen(context);
    }

    // Trường hợp 2: Đang tải session ban đầu từ local storage
    if (_isCheckingInitial) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang kiểm tra phiên đăng nhập...',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    // Trường hợp 3: Lắng nghe thay đổi phiên đăng nhập thời gian thực
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? AuthService.instance.currentSession;

        if (session != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  /// Màn hình thông báo hướng dẫn khi người dùng chưa điền key Supabase thực tế
  Widget _buildConfigurationPromptScreen(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechTrail - Cấu hình Supabase'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.settings_suggest_rounded,
                          color: Colors.amber,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cần cấu hình Supabase Key',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dịch vụ AuthService và Quản lý phiên đã sẵn sàng! '
                        'Để kết nối đến cơ sở dữ liệu Supabase PostgreSQL của bạn, vui lòng mở tệp:',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SelectableText(
                          'lib/config/supabase_config.dart',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Điền `url` và `anonKey` từ Supabase Project Dashboard của bạn vào tệp trên.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () async {
                          if (SupabaseConfig.isConfigured) {
                            await SupabaseService.init();
                            if (mounted) setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vẫn đang là key mẫu. Vui lòng cập nhật lib/config/supabase_config.dart trước.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử kết nối lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

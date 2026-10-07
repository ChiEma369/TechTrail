import 'package:flutter/material.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const TechTrailApp());
}

class TechTrailApp extends StatelessWidget {
  const TechTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF00796B);

    return MaterialApp(
      title: 'TechTrail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const StarterScreen(),
    );
  }
}

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInitialized = SupabaseService.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechTrail - Môi trường khởi động'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.terrain_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'TechTrail Mobile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dự án sẵn sàng phát triển từ đầu',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isInitialized ? Icons.check_circle : Icons.info_outline,
                        color: isInitialized ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isInitialized
                            ? 'Supabase: Đã kết nối'
                            : 'Supabase: Chưa kết nối',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Số lần bấm test Hot Reload: $_counter',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _counter++);
                },
                icon: const Icon(Icons.touch_app),
                label: const Text('Bấm thử tương tác'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

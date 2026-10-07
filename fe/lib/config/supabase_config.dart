class SupabaseConfig {
  static const String url = 'https://zwzfodmqvqnbwgbaqush.supabase.co/rest/v1/';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3emZvZG1xdnFuYndnYmFxdXNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MDA1NjUsImV4cCI6MjEwNDE3NjU2NX0.V6chJfXRA9EOJyKDMUb5DOel8rpK9c1CkupKI4bVi8A';

  static bool get isConfigured {
    return url.isNotEmpty &&
        !url.contains('https://zwzfodmqvqnbwgbaqush.supabase.co/rest/v1/') &&
        anonKey.isNotEmpty &&
        anonKey !=
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3emZvZG1xdnFuYndnYmFxdXNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MDA1NjUsImV4cCI6MjEwNDE3NjU2NX0.V6chJfXRA9EOJyKDMUb5DOel8rpK9c1CkupKI4bVi8A';
  }
}

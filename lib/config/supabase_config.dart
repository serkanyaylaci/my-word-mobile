class SupabaseConfig {
  // Replace with your Supabase Project URL and Anon Key
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key-placeholder',
  );

  static bool isConfigured() {
    return supabaseUrl != 'https://xyzcompany.supabase.co' &&
        supabaseAnonKey != 'public-anon-key-placeholder';
  }
}

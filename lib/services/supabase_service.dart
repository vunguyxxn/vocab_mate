import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    assert(url.isNotEmpty, 'SUPABASE_URL không được để trống');
    assert(anonKey.isNotEmpty, 'SUPABASE_ANON_KEY không được để trống');

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => client.auth.currentUser?.id;
  static bool get isLoggedIn => client.auth.currentUser != null;
}
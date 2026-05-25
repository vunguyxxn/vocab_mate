import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_service.dart';

class PremiumService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<bool> isPremiumActive(String userId) async {
    final subscription = await _client
        .from('subscriptions')
        .select('status, expires_at')
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('expires_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (subscription == null) {
      await _setProfilePremium(userId, false);
      return false;
    }

    final expiresAtRaw = subscription['expires_at'];

    if (expiresAtRaw == null) {
      await _setProfilePremium(userId, false);
      return false;
    }

    final expiresAt = DateTime.parse(expiresAtRaw.toString()).toLocal();
    final isActive = expiresAt.isAfter(DateTime.now());

    await _setProfilePremium(userId, isActive);

    return isActive;
  }

  static Future<void> activatePremium({
    required String plan,
    required int months,
  }) async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để nâng cấp Premium');
    }

    final now = DateTime.now();
    final expiresAt = DateTime(
      now.year,
      now.month + months,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    await _client
        .from('subscriptions')
        .update({
      'status': 'cancelled',
    })
        .eq('user_id', userId)
        .eq('status', 'active');

    await _client.from('subscriptions').insert({
      'user_id': userId,
      'plan': plan,
      'status': 'active',
      'started_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    });

    await _setProfilePremium(userId, true);
  }

  static Future<Map<String, dynamic>?> getCurrentSubscription() async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để xem Premium');
    }

    return await _client
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('expires_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  static Future<void> cancelPremium() async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để huỷ Premium');
    }

    await _client
        .from('subscriptions')
        .update({
      'status': 'cancelled',
    })
        .eq('user_id', userId)
        .eq('status', 'active');

    await _setProfilePremium(userId, false);
  }

  static Future<void> _setProfilePremium(
      String userId,
      bool isPremium,
      ) async {
    await _client.from('profiles').update({
      'is_premium': isPremium,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
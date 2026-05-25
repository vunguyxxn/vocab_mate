import '../../../services/supabase_service.dart';
import '../models/profile_model.dart';

class AuthService {
  static final _client = SupabaseService.client;

  static Future<ProfileModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final cleanEmail = email.trim();
    final cleanName = fullName.trim();

    try {
      final res = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'full_name': cleanName,
        },
      );

      final user = res.user;

      if (user == null) {
        throw Exception('Không thể tạo tài khoản. Vui lòng thử lại.');
      }

      ProfileModel? profile;

      for (var i = 0; i < 5; i++) {
        profile = await _tryGetProfile(user.id);

        if (profile != null) {
          return profile;
        }

        await Future.delayed(const Duration(milliseconds: 400));
      }

      await _client.from('profiles').insert({
        'id': user.id,
        'full_name': cleanName,
        'avatar_url': null,
        'total_score': 0,
        'total_quizzes': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'is_premium': false,
        'updated_at': DateTime.now().toIso8601String(),
      });

      profile = await _tryGetProfile(user.id);

      if (profile == null) {
        throw Exception('Không thể tải thông tin người dùng.');
      }

      return profile;
    } catch (e) {
      final hasSession = _client.auth.currentSession != null;

      if (hasSession) {
        final userId = _client.auth.currentUser?.id;

        if (userId != null) {
          final profile = await _tryGetProfile(userId);

          if (profile != null) {
            return profile;
          }
        }
      }

      throw Exception(_parseError(e));
    }
  }

  static Future<ProfileModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = res.user;

      if (user == null) {
        throw Exception('Đăng nhập thất bại');
      }

      return await getProfile(user.id);
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  static Future<ProfileModel> getProfile(String userId) async {
    final profile = await _tryGetProfile(userId);

    if (profile == null) {
      throw Exception('Không thể tải thông tin người dùng');
    }

    return profile;
  }

  static Future<ProfileModel?> _tryGetProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return ProfileModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static String _parseError(dynamic e) {
    final msg = e.toString().toLowerCase();

    if (msg.contains('user already registered') ||
        msg.contains('email already') ||
        msg.contains('already registered') ||
        msg.contains('duplicate key')) {
      return 'Email này đã được đăng ký';
    }

    if (msg.contains('invalid login')) {
      return 'Email hoặc mật khẩu không đúng';
    }

    if (msg.contains('weak password') || msg.contains('password')) {
      return 'Mật khẩu quá yếu hoặc không hợp lệ';
    }

    if (msg.contains('network') || msg.contains('socket')) {
      return 'Lỗi kết nối mạng';
    }

    return 'Đã có lỗi xảy ra, thử lại nhé';
  }
}
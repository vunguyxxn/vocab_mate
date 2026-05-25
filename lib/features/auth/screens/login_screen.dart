import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      // AuthGate tự điều hướng qua stream
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Logo + title
                  const Icon(Icons.auto_stories_rounded,
                      size: 64, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text('VocabMate',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Học từ vựng tiếng Anh mỗi ngày',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),

                  const SizedBox(height: 40),

                  // Card form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đăng nhập',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Chào mừng trở lại! 👋',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 24),

                        // Email field
                        _buildLabel('Email'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: 'example@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _buildLabel('Mật khẩu'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _passCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),

                        // Error message
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Login button
                        _buildGradientButton(
                          onTap: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                              : const Text('Đăng nhập',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),

                        const SizedBox(height: 16),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Chưa có tài khoản? ',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()),
                              ),
                              child: const Text('Đăng ký ngay',
                                  style: TextStyle(
                                      color: AppColors.indigo,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
            prefixIcon:
            Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: suffix,
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );

  Widget _buildGradientButton(
      {required Widget child, required VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: onTap == null
                ? const LinearGradient(
                colors: [Colors.grey, Colors.grey])
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: onTap == null
                ? []
                : [
              BoxShadow(
                color: AppColors.indigo.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      );
}
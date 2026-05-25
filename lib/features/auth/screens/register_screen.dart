import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final fullName = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirmPassword = _confirmCtrl.text;

    if (fullName.isEmpty) {
      setState(() => _error = 'Vui lòng nhập họ tên');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Email không hợp lệ');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.register(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo tài khoản thành công'),
        ),
      );

      // Không tự push HomeScreen.
      // AuthGate sẽ tự chuyển màn khi Supabase có session.
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _loading ? null : () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tạo tài khoản',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin đăng ký',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Họ và tên'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameCtrl,
                          hint: 'Nguyễn Văn A',
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('Email'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: 'example@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('Mật khẩu'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _passCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscurePass,
                          textInputAction: TextInputAction.next,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePass = !_obscurePass;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('Xác nhận mật khẩu'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _confirmCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildGradientButton(
                          onTap: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Tạo tài khoản',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required Widget child,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: onTap == null
              ? const LinearGradient(
            colors: [
              Colors.grey,
              Colors.grey,
            ],
          )
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onTap == null
              ? []
              : [
            BoxShadow(
              color: AppColors.indigo.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
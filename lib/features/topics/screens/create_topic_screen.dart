import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/supabase_service.dart';
import '../models/topic_model.dart';
import '../services/topic_service.dart';

class CreateTopicScreen extends StatefulWidget {
  final TopicModel? editTopic; // null = tạo mới, có = sửa
  const CreateTopicScreen({super.key, this.editTopic});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedIcon = 'custom';
  String _selectedVisibility = 'private';
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.editTopic != null;

  final _icons = [
    ('custom', '📖'),
    ('food', '🍜'),
    ('travel', '✈️'),
    ('school', '📚'),
    ('work', '💼'),
    ('health', '❤️'),
    ('technology', '💻'),
    ('sport', '⚽'),
    ('music', '🎵'),
    ('art', '🎨'),
    ('science', '🔬'),
    ('nature', '🌿'),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _titleCtrl.text = widget.editTopic!.title;
      _descCtrl.text = widget.editTopic!.description ?? '';
      _selectedIcon = widget.editTopic!.iconName ?? 'custom';
      _selectedVisibility = widget.editTopic!.visibility;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Vui lòng nhập tên chủ đề');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isEdit) {
        await TopicService.updateTopic(
          topicId: widget.editTopic!.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          iconName: _selectedIcon,
          visibility: _selectedVisibility,
        );
      } else {
        await TopicService.createTopic(
          userId: SupabaseService.currentUserId!,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          iconName: _selectedIcon,
          visibility: _selectedVisibility,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF4F46E5),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _isEdit ? '✏️ Sửa chủ đề' : '➕ Tạo chủ đề mới',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text('Chủ đề từ vựng cá nhân của bạn',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên chủ đề
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tên chủ đề *'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleCtrl,
                          hint: 'VD: Từ vựng IELTS, Tiếng Anh thương mại...',
                          icon: Icons.title_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Mô tả (tuỳ chọn)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descCtrl,
                          hint: 'Mô tả ngắn về chủ đề này...',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn icon
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Chọn biểu tượng'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _icons.map((item) {
                            final isSelected = _selectedIcon == item.$1;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedIcon = item.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.indigo.withOpacity(0.15)
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.indigo
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(item.$2,
                                      style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Visibility
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Quyền truy cập'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildVisibilityOption(
                              'private',
                              '🔒',
                              'Riêng tư',
                              'Chỉ mình bạn',
                            ),
                            const SizedBox(width: 10),
                            _buildVisibilityOption(
                              'public',
                              '🌍',
                              'Công khai',
                              'Mọi người thấy',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
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
                                    color: AppColors.error, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Save button
                  GestureDetector(
                    onTap: _loading ? null : _save,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.indigo.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : Text(
                          _isEdit ? 'Lưu thay đổi' : 'Tạo chủ đề',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                      ),
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

  Widget _buildVisibilityOption(
      String value, String emoji, String title, String subtitle) {
    final isSelected = _selectedVisibility == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedVisibility = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.indigo.withOpacity(0.08)
                : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.indigo : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.indigo
                          : AppColors.textPrimary)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
          ),
        ),
      );
}
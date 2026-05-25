import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/supabase_service.dart';
import '../../topics/models/topic_model.dart';
import '../models/vocabulary_model.dart';
import '../services/vocabulary_service.dart';

class CreateVocabularyScreen extends StatefulWidget {
  final TopicModel topic;
  final VocabularyModel? editVocab;
  const CreateVocabularyScreen(
      {super.key, required this.topic, this.editVocab});

  @override
  State<CreateVocabularyScreen> createState() =>
      _CreateVocabularyScreenState();
}

class _CreateVocabularyScreenState extends State<CreateVocabularyScreen> {
  final _wordCtrl = TextEditingController();
  final _phoneticCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _exampleEnCtrl = TextEditingController();
  final _exampleViCtrl = TextEditingController();
  String _partOfSpeech = 'noun';
  String _difficulty = 'medium';
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.editVocab != null;

  final _posList = ['noun', 'verb', 'adjective', 'adverb', 'phrase'];
  final _diffList = ['easy', 'medium', 'hard'];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final v = widget.editVocab!;
      _wordCtrl.text = v.word;
      _phoneticCtrl.text = v.phonetic ?? '';
      _meaningCtrl.text = v.meaningVi;
      _exampleEnCtrl.text = v.exampleEn ?? '';
      _exampleViCtrl.text = v.exampleVi ?? '';
      _partOfSpeech = v.partOfSpeech ?? 'noun';
      _difficulty = v.difficultyLevel;
    }
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _phoneticCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleEnCtrl.dispose();
    _exampleViCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_wordCtrl.text.trim().isEmpty || _meaningCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Vui lòng nhập từ vựng và nghĩa');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isEdit) {
        await VocabularyService.updateVocabulary(
          vocabId: widget.editVocab!.id,
          word: _wordCtrl.text.trim(),
          meaningVi: _meaningCtrl.text.trim(),
          phonetic: _phoneticCtrl.text.trim().isEmpty
              ? null : _phoneticCtrl.text.trim(),
          partOfSpeech: _partOfSpeech,
          exampleEn: _exampleEnCtrl.text.trim().isEmpty
              ? null : _exampleEnCtrl.text.trim(),
          exampleVi: _exampleViCtrl.text.trim().isEmpty
              ? null : _exampleViCtrl.text.trim(),
          difficultyLevel: _difficulty,
        );
      } else {
        await VocabularyService.createVocabulary(
          topicId: widget.topic.id,
          userId: SupabaseService.currentUserId!,
          word: _wordCtrl.text.trim(),
          meaningVi: _meaningCtrl.text.trim(),
          phonetic: _phoneticCtrl.text.trim().isEmpty
              ? null : _phoneticCtrl.text.trim(),
          partOfSpeech: _partOfSpeech,
          exampleEn: _exampleEnCtrl.text.trim().isEmpty
              ? null : _exampleEnCtrl.text.trim(),
          exampleVi: _exampleViCtrl.text.trim().isEmpty
              ? null : _exampleViCtrl.text.trim(),
          difficultyLevel: _difficulty,
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
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFFEC4899),
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
                    gradient: AppColors.pinkGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _isEdit ? '✏️ Sửa từ vựng' : '➕ Thêm từ vựng',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900),
                        ),
                        Text('${widget.topic.emoji} ${widget.topic.title}',
                            style: const TextStyle(
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
                children: [
                  // Từ vựng + phonetic
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Từ vựng *'),
                        const SizedBox(height: 8),
                        _buildTextField(_wordCtrl, 'VD: beautiful', Icons.abc),
                        const SizedBox(height: 14),
                        _buildLabel('Phiên âm (tuỳ chọn)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                            _phoneticCtrl, 'VD: /ˈbjuː.tɪ.fəl/', Icons.record_voice_over_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nghĩa
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nghĩa tiếng Việt *'),
                        const SizedBox(height: 8),
                        _buildTextField(
                            _meaningCtrl, 'VD: đẹp, xinh đẹp', Icons.translate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Part of speech + difficulty
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Loại từ'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: _posList.map((pos) {
                            final selected = _partOfSpeech == pos;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _partOfSpeech = pos),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.indigo
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(pos,
                                    style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Độ khó'),
                        const SizedBox(height: 10),
                        Row(
                          children: _diffList.map((d) {
                            final selected = _difficulty == d;
                            final color = d == 'easy'
                                ? AppColors.success
                                : d == 'hard'
                                ? AppColors.error
                                : AppColors.warning;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _difficulty = d),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? color.withOpacity(0.15)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? color
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      d == 'easy'
                                          ? '😊 Dễ'
                                          : d == 'hard'
                                          ? '🔥 Khó'
                                          : '😐 TB',
                                      style: TextStyle(
                                          color: selected
                                              ? color
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Ví dụ
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Câu ví dụ tiếng Anh (tuỳ chọn)'),
                        const SizedBox(height: 8),
                        _buildTextField(_exampleEnCtrl,
                            'VD: She is beautiful.', Icons.format_quote),
                        const SizedBox(height: 14),
                        _buildLabel('Dịch nghĩa câu ví dụ (tuỳ chọn)'),
                        const SizedBox(height: 8),
                        _buildTextField(_exampleViCtrl,
                            'VD: Cô ấy rất đẹp.', Icons.translate_outlined),
                      ],
                    ),
                  ),

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

                  GestureDetector(
                    onTap: _loading ? null : _save,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.pinkGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withOpacity(0.35),
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
                          _isEdit ? 'Lưu thay đổi' : 'Thêm từ vựng',
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

  Widget _buildTextField(
      TextEditingController ctrl, String hint, IconData icon) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
          ),
        ),
      );
}
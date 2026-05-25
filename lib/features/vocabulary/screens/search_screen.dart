import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/vocabulary_model.dart';
import '../services/vocabulary_service.dart';
import '../../../services/supabase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  List<VocabularyModel> _results = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _hasSearched = false; });
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await VocabularyService.searchVocabularies(
        query: query.trim(),
        userId: SupabaseService.currentUserId,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _hasSearched = true;
          _loading = false;
        });
      }
    } catch (_) {
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
                        const Text('🔍 Tìm kiếm từ vựng',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        const Text('Tìm trong tất cả chủ đề',
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
                children: [
                  // Search box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: (v) {
                        if (v.length >= 2 || v.isEmpty) _search(v);
                      },
                      onSubmitted: _search,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Nhập từ tiếng Anh hoặc nghĩa tiếng Việt...',
                        hintStyle: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.indigo),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            _search('');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Results
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.indigo),
                    )
                  else if (!_hasSearched)
                    _buildHint()
                  else if (_results.isEmpty)
                      _buildEmpty()
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_results.length} kết quả',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          ..._results.map(_buildResultCard),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(VocabularyModel vocab) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('🔤', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(vocab.word,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary)),
                  const SizedBox(width: 6),
                  if (vocab.phonetic != null)
                    Text(vocab.phonetic!,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 3),
              Text(vocab.meaningVi,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.indigo)),
              if (vocab.exampleEn != null) ...[
                const SizedBox(height: 4),
                Text(vocab.exampleEn!,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
        // Difficulty badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: vocab.difficultyLevel == 'easy'
                ? const Color(0xFFD1FAE5)
                : vocab.difficultyLevel == 'hard'
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            vocab.difficultyLevel,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: vocab.difficultyLevel == 'easy'
                    ? AppColors.success
                    : vocab.difficultyLevel == 'hard'
                    ? AppColors.error
                    : AppColors.warning),
          ),
        ),
      ],
    ),
  );

  Widget _buildHint() => Column(
    children: [
      const SizedBox(height: 40),
      Icon(Icons.search_rounded, size: 80,
          color: AppColors.indigo.withOpacity(0.2)),
      const SizedBox(height: 16),
      const Text('Tìm kiếm từ vựng',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      const Text('Nhập ít nhất 2 ký tự để tìm kiếm',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 13)),
    ],
  );

  Widget _buildEmpty() => Column(
    children: [
      const SizedBox(height: 40),
      Icon(Icons.find_in_page_outlined,
          size: 80, color: AppColors.indigo.withOpacity(0.2)),
      const SizedBox(height: 16),
      const Text('Không tìm thấy kết quả',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Thử tìm với từ khác nhé',
          style: TextStyle(color: AppColors.textSecondary)),
    ],
  );
}
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_message_model.dart';
import '../services/chat_firestore_service.dart';
import '../widgets/chat_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _sessionId;
  bool _loading = true;
  bool _sending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final sessionId = await ChatFirestoreService.getOrCreateSession();

      if (!mounted) return;

      setState(() {
        _sessionId = sessionId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _send() async {
    final sessionId = _sessionId;
    final text = _controller.text.trim();

    if (sessionId == null || text.isEmpty || _sending) return;

    _controller.clear();

    setState(() => _sending = true);

    try {
      await ChatFirestoreService.sendMessage(
        sessionId: sessionId,
        message: text,
      );

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _clearChat() async {
    final sessionId = _sessionId;

    if (sessionId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Xoá đoạn chat?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Toàn bộ tin nhắn trong đoạn chat này sẽ bị xoá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xoá',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ChatFirestoreService.clearSession(sessionId);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = _sessionId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.indigo,
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildError(),
            )
          else if (sessionId == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(),
              )
            else
              SliverFillRemaining(
                hasScrollBody: true,
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<ChatMessageModel>>(
                        stream: ChatFirestoreService.watchMessages(sessionId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.indigo,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  snapshot.error.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            );
                          }

                          final messages = snapshot.data ?? [];

                          if (messages.isEmpty) {
                            return _buildEmpty();
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return ChatBubble(
                                message: messages[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    _buildInputBar(),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 170,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.indigo,
      actions: [
        IconButton(
          onPressed: _clearChat,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'VocabMate AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                top: -25,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                right: 28,
                bottom: 45,
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 72,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không mở được Chatbot',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (_errorMessage ?? 'Đã có lỗi xảy ra')
                .replaceFirst('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _initChat,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 72,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Bắt đầu hỏi VocabMate AI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hỏi về từ vựng, ví dụ câu, phát âm hoặc ngữ pháp tiếng Anh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Hỏi VocabMate AI...',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _sending ? null : AppColors.primaryGradient,
                  color: _sending ? AppColors.textSecondary : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.indigo.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _sending
                    ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
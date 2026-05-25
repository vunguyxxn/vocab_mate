import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: message.isLoading
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isUser ? Colors.white : AppColors.indigo,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        )
            : Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14.5,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
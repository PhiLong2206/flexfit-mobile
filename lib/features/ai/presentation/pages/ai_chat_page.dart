import 'package:flutter/material.dart';
import '../../data/models/ai_suggestion_model.dart';
import '../../data/repositories/ai_repository.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  static const Color _primaryOrange = Color(0xFFFF6B16);
  static const Color _backgroundColor = Color(0xFF070B14);
  static const Color _cardColor = Color(0xFF111827);
  static const Color _borderColor = Color(0xFF2A3647);

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiRepository _aiRepository = AiRepository();
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default greeting from AI Coach
    _messages.add(
      ChatMessageModel(
        text: 'Xin chào! Tôi là AI Coach của bạn. Tôi có thể giúp bạn lên lịch tập luyện, gợi ý lớp học phù hợp hoặc trả lời các thắc mắc về dinh dưỡng. Hôm nay bạn muốn tập luyện thế nào?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessageModel(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await _aiRepository.sendChatMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessageModel(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessageModel(
          text: 'Xin lỗi, đã xảy ra lỗi khi kết nối với máy chủ AI Coach. Vui lòng thử lại sau.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AiChatPage._backgroundColor,
      appBar: AppBar(
        backgroundColor: AiChatPage._cardColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AiChatPage._primaryOrange, Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AiChatPage._primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI Coach Trợ lý',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Đang hoạt động',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return const _TypingIndicator();
                  }
                  final message = _messages[index];
                  return _MessageBubble(message: message);
                },
              ),
            ),
            _buildInputArea(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AiChatPage._cardColor,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AiChatPage._backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AiChatPage._borderColor.withValues(alpha: 0.5)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Hỏi AI Coach về lịch tập, chế độ ăn...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AiChatPage._primaryOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AiChatPage._primaryOrange.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              height: 32,
              width: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF1B263B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF6B16), size: 15),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFFF6B16) : const Color(0xFF111827),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Text(
                message.text,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.4,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF1B263B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF6B16), size: 15),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const SizedBox(
              width: 30,
              height: 18,
              child: Center(
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

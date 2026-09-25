import 'package:flutter/material.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'message':
          "Hi! I'm your AI nutrition assistant 🌱\n\nI can help you with meals, calories, protein, healthy recipes, and your diet goals.",
    },
  ];

  final List<String> _quickQuestions = [
    'What should I eat today?',
    'Protein rich foods',
    'How many calories do I need?',
    'Give me a healthy recipe',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickMessage]) {
    final message = quickMessage ?? _messageController.text.trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'message': message});

      _messages.add({
        'isUser': false,
        'message':
            "I'm preparing a personalized answer for you 🌱\n\nAI responses will be connected here next.",
      });
    });

    _messageController.clear();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8EF),

      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 95),
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEBC5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF123F29),
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Nutrition Assistant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF123F29),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your personal nutrition guide',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // TITLE
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'How can I help you today?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF193A26),
                    ),
                  ),
                ),
              ),

              // CHAT AREA
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final bool isUser = message['isUser'] as bool;

                    return _messageBubble(message['message'] as String, isUser);
                  },
                ),
              ),

              // QUICK QUESTIONS
              SizedBox(
                height: 58,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickQuestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ActionChip(
                      label: Text(_quickQuestions[index]),

                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFD5E3CF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      labelStyle: const TextStyle(
                        color: Color(0xFF28633D),
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    );
                  },
                ),
              ),

              // CHATBOX
              Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                decoration: const BoxDecoration(color: Color(0xFFF4F8EF)),
                child: Row(
                  children: [
                    Expanded(
                      child: // CHATBOX
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: const Color(0xFFDCE3D7),
                                  ),
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _sendMessage(),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Ask me anything about nutrition...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: Color(0xFF28633D),
                                      size: 21,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                color: Color(0xFF14502F),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _sendMessage,
                                icon: const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF14502F),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF286B43) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFE1E0D8)),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isUser ? Colors.white : const Color(0xFF315540),
          ),
        ),
      ),
    );
  }
}

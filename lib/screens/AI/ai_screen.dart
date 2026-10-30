import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'message':
          "Hi! I'm your AI nutrition assistant 🌱\n\n"
          'I can help you with meals, calories, protein, '
          'healthy recipes, and your diet goals.',
    },
  ];

  final List<String> _quickQuestions = [
    'What should I eat today?',
    'Protein rich foods',
    'How many calories do I need?',
    'Give me a healthy recipe',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _getProfileContext() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'The user is not logged in. Do not assume any profile details.';
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();

      if (data == null) {
        return 'No saved nutrition profile is available.';
      }

      return '''
            User's saved nutrition profile:
            - Age: ${data['age'] ?? 'Not provided'}
            - Height: ${data['height'] ?? 'Not provided'}
            - Weight: ${data['weight'] ?? 'Not provided'}
            - Gender: ${data['gender'] ?? 'Not provided'}
            - Activity level: ${data['activityLevel'] ?? 'Not provided'}
            - Fitness goal: ${data['goal'] ?? 'Not provided'}
            - Diet preference: ${data['dietPreference'] ?? 'Not provided'}
            - Food allergies/restrictions: ${data['allergies'] ?? 'Not provided'}
            - Health conditions: ${data['healthConditions'] ?? 'Not provided'}
            - Daily calorie target: ${data['dailyCalories'] ?? 'Not calculated'}
            - Daily protein target (grams): ${data['protein'] ?? 'Not calculated'}
            - Daily carbohydrates target (grams): ${data['carbohydrates'] ?? 'Not calculated'}
            - Daily fats target (grams): ${data['fats'] ?? 'Not calculated'}
            ''';
    } catch (_) {
      return 'The saved profile could not be loaded. '
          'Do not assume missing personal details.';
    }
  }

  Future<void> _sendMessage([String? quickMessage]) async {
    if (_isSending) return;

    final message = (quickMessage ?? _messageController.text).trim();

    if (message.isEmpty) return;

    final assistantIndex = _messages.length + 1;

    setState(() {
      _isSending = true;

      _messages.add({'isUser': true, 'message': message});

      _messages.add({'isUser': false, 'message': 'Thinking... 🌱'});
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final profileContext = await _getProfileContext();

      final prompt =
          '''
You are the AI Nutrition Assistant in a college mini-project
called Plan My Diet.

Give friendly, clear, practical nutrition guidance.
Adapt suggestions to the user's saved diet preference,
food allergies, health conditions, and nutrition targets.

IMPORTANT RULES:
- Never invent missing user profile details.
- Respect all reported food allergies and restrictions.
- If an allergy makes a suggested food unsuitable, do not recommend it.
- Offer vegetarian foods when the user's preference is vegetarian.
- Give approximate food quantities and explain that nutrition values vary.
- Use the saved calorie and macronutrient targets when relevant.
- Do not claim that a food is medically safe for a particular person.
- Do not diagnose conditions or recommend changing medication.
- For medical nutrition advice involving a health condition,
  encourage the user to consult a qualified healthcare professional.
- If profile information is missing, ask a short follow-up when necessary.
- Use readable formatting and avoid unnecessarily long answers.

$profileContext

User's question:
$message
''';

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent',
      );

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _apiKey,
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'maxOutputTokens': 400, 'temperature': 0.4},
            }),
          )
          .timeout(const Duration(seconds: 45));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        final error = data['error'] as Map<String, dynamic>?;
        throw Exception(
          error?['message'] ??
              'Gemini request failed (${response.statusCode}).',
        );
      }

      final candidates = data['candidates'] as List<dynamic>? ?? [];

      if (candidates.isEmpty) {
        throw Exception('Gemini returned no response.');
      }

      final candidate = candidates.first as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>? ?? [];

      final answer = parts
          .whereType<Map<String, dynamic>>()
          .map((part) => part['text']?.toString() ?? '')
          .join()
          .trim();

      if (answer.isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      if (!mounted) return;

      setState(() {
        _messages[assistantIndex]['message'] = answer;
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages[assistantIndex]['message'] =
            'Sorry, I could not get an AI response. Please try again.\n\n'
            'Error details: $e';

        _isSending = false;
      });
    }

    _scrollToBottom();
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
                    const Expanded(
                      child: Column(
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

                    return _messageBubble(
                      message['message'] as String,
                      message['isUser'] as bool,
                    );
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ActionChip(
                      onPressed: _isSending
                          ? null
                          : () => _sendMessage(_quickQuestions[index]),
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

              // SINGLE CHAT INPUT
              Container(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFDCE3D7)),
                        ),
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isSending,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            hintText: 'Ask me anything about nutrition...',
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
                        onPressed: _isSending ? null : _sendMessage,
                        icon: _isSending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
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
        child: SelectableText(
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

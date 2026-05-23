import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../widgets/glass_card.dart';

class AiChatScreen extends StatefulWidget {
  final WeatherProvider provider;
  const AiChatScreen({super.key, required this.provider});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // Quick question suggestions
  static const _quickQuestions = [
    '☂️ Need an umbrella today?',
    '🏃 Good day for outdoor exercise?',
    '👕 What should I wear?',
    '🌡️ How hot does it feel?',
    '🚗 Safe to drive?',
    '📸 Good for photography?',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcome();
  }

  void _addWelcome() {
    final w = widget.provider.currentWeather;
    if (w == null) return;

    final greeting =
        'Hello! I\'m SkyCast AI 🌤️\n\n'
        'Current weather in **${w.cityName}**: '
        '${WeatherUtils.emojiForCondition(w.condition)} '
        '${w.temp.round()}°C, ${w.description}.\n\n'
        'Ask me anything — should you go out? Need an umbrella? '
        'What to wear? I\'m here to help! 😊';

    _messages.add(_ChatMessage(text: greeting, isUser: false));
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isTyping) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _isTyping = true;
    });

    _scrollToBottom();

    final reply = await widget.provider.gemini.sendMessage(text.trim());

    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.provider.currentWeather;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF12002E),
              Color(0xFF1A0050),
              Color(0xFF0D1B4B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              _buildHeader(w?.cityName ?? ''),

              // ── Message list ──────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount:
                      _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == _messages.length && _isTyping) {
                      return _TypingIndicator();
                    }
                    return _MessageBubble(
                      message: _messages[i],
                      index: i,
                    );
                  },
                ),
              ),

              // ── Quick suggestions ─────────────────────────────────────────
              if (_messages.length < 3) _buildQuickSuggestions(),

              // ── Input bar ─────────────────────────────────────────────────
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(String city) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),

              // AI avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 20))),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SkyCast AI',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF69F0AE),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fadeIn(duration: 800.ms),
                        Text(
                          city.isNotEmpty
                              ? 'Analyzing $city weather'
                              : 'Online',
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Powered by badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A73E8).withOpacity(0.3),
                      const Color(0xFF4285F4).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4285F4).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✦ ',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF82B1FF), fontSize: 10)),
                    Text(
                      'Gemini',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF82B1FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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

  // ── Quick suggestions ────────────────────────────────────────────────────
  Widget _buildQuickSuggestions() {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _quickQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTap: () => _send(_quickQuestions[i]),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Text(
                _quickQuestions[i],
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: i * 60))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  // ── Input bar ────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          child: Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: 24,
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 14),
                    cursorColor: const Color(0xFF9C27B0),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Ask me about the weather…',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white30, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: _send,
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _send(_controller.text),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isTyping
                          ? [Colors.grey.shade700, Colors.grey.shade800]
                          : [
                              const Color(0xFF7B1FA2),
                              const Color(0xFF9C27B0),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: _isTyping
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white54,
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final int index;

  const _MessageBubble({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                )
              : null,
          color: isUser ? null : Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
            height: 1.5,
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0);
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white54,
              ),
            )
                .animate(
                  delay: Duration(milliseconds: i * 200),
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .moveY(begin: 0, end: -6, duration: 400.ms,
                    curve: Curves.easeInOut);
          }),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

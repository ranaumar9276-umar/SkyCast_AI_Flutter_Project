import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _searching = false;

  // Popular cities for quick access
  static const _popular = [
    ('🇵🇰', 'Karachi'), ('🇵🇰', 'Lahore'), ('🇵🇰', 'Islamabad'),
    ('🇬🇧', 'London'), ('🇺🇸', 'New York'), ('🇦🇪', 'Dubai'),
    ('🇸🇦', 'Riyadh'), ('🇹🇷', 'Istanbul'), ('🇩🇪', 'Berlin'),
    ('🇫🇷', 'Paris'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _search(String city) async {
    if (city.trim().isEmpty) return;
    setState(() => _searching = true);
    final provider = context.read<WeatherProvider>();
    await provider.fetchByCity(city);
    if (!mounted) return;
    setState(() => _searching = false);
    if (provider.status == AppStatus.loaded) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error,
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: const Color(0xFF1A237E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: Colors.white54, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focus,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                cursorColor: Colors.white60,
                                decoration: InputDecoration(
                                  hintText: 'Search city...',
                                  hintStyle: GoogleFonts.poppins(
                                      color: Colors.white38, fontSize: 15),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: _search,
                                textInputAction: TextInputAction.search,
                              ),
                            ),
                            if (_searching)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white54,
                                ),
                              )
                            else if (_controller.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white38, size: 18),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // ── Scrollable content ────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Recent searches
                    if (provider.recentSearches.isNotEmpty) ...[
                      _sectionLabel('RECENT SEARCHES'),
                      const SizedBox(height: 10),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: List.generate(
                            provider.recentSearches.length,
                            (i) {
                              final city = provider.recentSearches[i];
                              return _CityTile(
                                leading: const Icon(Icons.history_rounded,
                                    color: Colors.white38, size: 18),
                                title: city,
                                isLast: i == provider.recentSearches.length - 1,
                                onTap: () => _search(city),
                              );
                            },
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 24),
                    ],

                    // Popular cities
                    _sectionLabel('POPULAR CITIES'),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: List.generate(_popular.length, (i) {
                          final (flag, city) = _popular[i];
                          return _CityTile(
                            leading: Text(flag,
                                style: const TextStyle(fontSize: 18)),
                            title: city,
                            isLast: i == _popular.length - 1,
                            onTap: () => _search(city),
                          );
                        }),
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white38,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final bool isLast;
  final VoidCallback onTap;

  const _CityTile({
    required this.leading,
    required this.title,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                      color: Colors.white.withOpacity(0.07), width: 1)),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
             Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.2), size: 14),
          ],
        ),
      ),
    );
  }
}

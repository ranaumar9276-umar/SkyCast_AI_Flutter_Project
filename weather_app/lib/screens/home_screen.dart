import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';
import 'search_screen.dart';
import 'ai_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (ctx, provider, _) {
        switch (provider.status) {
          case AppStatus.loading:
          case AppStatus.initial:
            return const _LoadingView();
          case AppStatus.error:
            return _ErrorView(message: provider.error, provider: provider);
          case AppStatus.loaded:
            return _WeatherView(provider: provider);
        }
      },
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.05),
            highlightColor: Colors.white.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  _shimmerBox(140, 22, radius: 12),
                  const SizedBox(height: 60),
                  _shimmerBox(100, 100, radius: 50),
                  const SizedBox(height: 24),
                  _shimmerBox(180, 80, radius: 12),
                  const SizedBox(height: 12),
                  _shimmerBox(220, 20, radius: 8),
                  const SizedBox(height: 40),
                  _shimmerBox(double.infinity, 130, radius: 20),
                  const SizedBox(height: 20),
                  _shimmerBox(double.infinity, 120, radius: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(double w, double h, {double radius = 8}) {
    return Container(
      width: w == double.infinity ? double.infinity : w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final WeatherProvider provider;
  const _ErrorView({required this.message, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1628), Color(0xFF1A237E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 20),
                  Text(
                    'Something went wrong',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: provider.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('Try Again',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SearchScreen()),
                    ),
                    child: Text(
                      'Search a city instead',
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Main weather view ─────────────────────────────────────────────────────────

class _WeatherView extends StatelessWidget {
  final WeatherProvider provider;
  const _WeatherView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final w = provider.currentWeather!;
    final now = DateTime.now();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        weather: w,
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          backgroundColor: Colors.white12,
          color: Colors.white,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar ──────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 0,
                pinned: true,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${w.cityName}, ${w.country}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white54, size: 18),
                    ],
                  ),
                ),
                actions: [
                  // Unit toggle
                  GestureDetector(
                    onTap: provider.toggleUnit,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                      child: Text(
                        provider.tempUnit,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Content ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Date
                      Text(
                        DateFormat('EEEE, d MMMM').format(now),
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 600.ms),

                      const SizedBox(height: 32),

                      // Weather emoji / icon
                      Text(
                        WeatherUtils.emojiForCondition(w.condition),
                        style: const TextStyle(fontSize: 80),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.3, 0.3),
                            duration: 700.ms,
                            curve: Curves.elasticOut,
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(
                            begin: 0,
                            end: -10,
                            duration: 3.seconds,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 16),

                      // Temperature
                      Text(
                        '${provider.displayTemp(w.temp).round()}${provider.tempUnit}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 88,
                          fontWeight: FontWeight.w200,
                          height: 1,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 8),

                      // Condition
                      Text(
                        w.description.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.5,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms),

                      const SizedBox(height: 6),

                      // Min / Max
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'H ${provider.displayTemp(w.tempMax).round()}°  '
                            'L ${provider.displayTemp(w.tempMin).round()}°',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 600.ms),

                      const SizedBox(height: 30),

                      // ── Detail card ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 2.4,
                            children: [
                              _DetailItem(
                                icon: Icons.water_drop_rounded,
                                iconColor: const Color(0xFF81D4FA),
                                label: 'Humidity',
                                value: '${w.humidity}%',
                              ),
                              _DetailItem(
                                icon: Icons.air_rounded,
                                iconColor: const Color(0xFF80DEEA),
                                label: 'Wind',
                                value:
                                    '${w.windSpeed.toStringAsFixed(1)} m/s ${WeatherUtils.windDirection(w.windDeg)}',
                              ),
                              _DetailItem(
                                icon: Icons.visibility_rounded,
                                iconColor: const Color(0xFFB39DDB),
                                label: 'Visibility',
                                value:
                                    WeatherUtils.formatVisibility(w.visibility),
                              ),
                              _DetailItem(
                                icon: Icons.compress_rounded,
                                iconColor: const Color(0xFFA5D6A7),
                                label: 'Pressure',
                                value: '${w.pressure} hPa',
                              ),
                              _DetailItem(
                                icon: Icons.thermostat_rounded,
                                iconColor: const Color(0xFFFFCC80),
                                label: 'Feels Like',
                                value:
                                    '${provider.displayTemp(w.feelsLike).round()}${provider.tempUnit}',
                              ),
                              _DetailItem(
                                icon: Icons.cloud_rounded,
                                iconColor: const Color(0xFFECEFF1),
                                label: 'Cloud Cover',
                                value: '${w.cloudiness}%',
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 28),

                      // ── Sunrise / Sunset ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SunItem(
                                  emoji: '🌅',
                                  label: 'Sunrise',
                                  time: WeatherUtils.shortHour(w.sunrise),
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withOpacity(0.15)),
                              Expanded(
                                child: _SunItem(
                                  emoji: '🌇',
                                  label: 'Sunset',
                                  time: WeatherUtils.shortHour(w.sunset),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 450.ms, duration: 600.ms),

                      const SizedBox(height: 28),

                      // ── Hourly Forecast ──────────────────────────────────
                      HourlyForecastWidget(
                        items: provider.hourly,
                        isCelsius: provider.isCelsius,
                        convert: provider.displayTemp,
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 600.ms),

                      const SizedBox(height: 28),

                      // ── Daily Forecast ───────────────────────────────────
                      DailyForecastWidget(
                        items: provider.daily,
                        isCelsius: provider.isCelsius,
                        convert: provider.displayTemp,
                      )
                          .animate()
                          .fadeIn(delay: 550.ms, duration: 600.ms),

                      const SizedBox(height: 20),

                      // Last updated
                      Text(
                        'Updated ${DateFormat('h:mm a').format(w.lastUpdated)}',
                        style: GoogleFonts.poppins(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                      ),

                      // Bottom padding for FAB
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── AI FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: _AiFab(provider: provider)
          .animate(delay: 800.ms)
          .scale(
            begin: const Offset(0, 0),
            duration: 500.ms,
            curve: Curves.elasticOut,
          ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SunItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String time;

  const _SunItem(
      {required this.emoji, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
              color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class _AiFab extends StatefulWidget {
  final WeatherProvider provider;
  const _AiFab({required this.provider});

  @override
  State<_AiFab> createState() => _AiFabState();
}

class _AiFabState extends State<_AiFab> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (ctx, child) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AiChatScreen(provider: widget.provider),
            ),
          ),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7B1FA2),
                  const Color(0xFF9C27B0)
                      .withOpacity(0.8 + _pulse.value * 0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0)
                      .withOpacity(0.3 + _pulse.value * 0.3),
                  blurRadius: 18 + _pulse.value * 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🤖', style: TextStyle(fontSize: 24)),
                SizedBox(height: 1),
                Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

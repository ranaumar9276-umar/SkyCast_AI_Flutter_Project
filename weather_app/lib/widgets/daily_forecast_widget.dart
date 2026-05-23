import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/forecast_model.dart';
import '../utils/weather_utils.dart';
import 'glass_card.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<ForecastModel> items;
  final bool isCelsius;
  final double Function(double) convert;

  const DailyForecastWidget({
    super.key,
    required this.items,
    required this.isCelsius,
    required this.convert,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white54, size: 16),
                const SizedBox(width: 6),
                Text(
                  '7-DAY FORECAST',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(items.length, (i) {
                final f = items[i];
                return _DailyRow(
                  forecast: f,
                  isCelsius: isCelsius,
                  convert: convert,
                  isLast: i == items.length - 1,
                  index: i,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final ForecastModel forecast;
  final bool isCelsius;
  final double Function(double) convert;
  final bool isLast;
  final int index;

  const _DailyRow({
    required this.forecast,
    required this.isCelsius,
    required this.convert,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: Colors.white.withOpacity(0.08), width: 1)),
      ),
      child: Row(
        children: [
          // Day
          SizedBox(
            width: 46,
            child: Text(
              index == 0 ? 'Today' : WeatherUtils.dayName(forecast.dateTime),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Rain probability
          SizedBox(
            width: 44,
            child: forecast.pop > 0.1
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💧', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 2),
                      Text(
                        '${(forecast.pop * 100).round()}%',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF81D4FA),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // Condition emoji
          Expanded(
            child: Text(
              WeatherUtils.emojiForCondition(forecast.condition),
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),

          // Temp range
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${convert(forecast.tempMax).round()}°',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${convert(forecast.tempMin).round()}°',
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 70))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

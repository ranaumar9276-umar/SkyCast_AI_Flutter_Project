import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/forecast_model.dart';
import '../utils/weather_utils.dart';
import 'glass_card.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<ForecastModel> items;
  final bool isCelsius;
  final double Function(double) convert;

  const HourlyForecastWidget({
    super.key,
    required this.items,
    required this.isCelsius,
    required this.convert,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(
                'HOURLY FORECAST',
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
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (ctx, i) => _HourlyItem(
              item: items[i],
              isCelsius: isCelsius,
              convert: convert,
              index: i,
            ),
          ),
        ),
      ],
    );
  }
}

class _HourlyItem extends StatelessWidget {
  final ForecastModel item;
  final bool isCelsius;
  final double Function(double) convert;
  final int index;

  const _HourlyItem({
    required this.item,
    required this.isCelsius,
    required this.convert,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        borderRadius: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WeatherUtils.shortHour(item.dateTime),
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              WeatherUtils.emojiForCondition(item.condition),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              '${convert(item.temp).round()}°',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item.pop > 0.1)
              Text(
                '${(item.pop * 100).round()}%',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF81D4FA),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.15, end: 0);
  }
}

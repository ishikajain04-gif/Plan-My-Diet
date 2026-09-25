import 'package:flutter/material.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              const SizedBox(height: 26),

              _weightCard(),

              const SizedBox(height: 18),

              _statsRow(),

              const SizedBox(height: 28),

              const Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF193A26),
                ),
              ),

              const SizedBox(height: 14),

              _weeklyChart(),

              const SizedBox(height: 28),

              const Text(
                "Today's Goals",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF193A26),
                ),
              ),

              const SizedBox(height: 14),

              _goalCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Calories',
                value: '1,420 / 2,000 kcal',
                progress: 0.71,
              ),

              const SizedBox(height: 12),

              _goalCard(
                icon: Icons.water_drop_rounded,
                title: 'Water',
                value: '5 / 8 glasses',
                progress: 0.625,
              ),

              const SizedBox(height: 22),

              _motivationCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF193A26),
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Small steps. Real progress.',
          style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
        ),
      ],
    );
  }

  // ============================================================
  // WEIGHT CARD
  // ============================================================

  Widget _weightCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF245936),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF245936).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEIGHT PROGRESS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(
                Icons.monitor_weight_outlined,
                color: Colors.white70,
                size: 21,
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '57',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  'kg',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Current weight',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.58,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFDCEBC5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Starting: 62 kg',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                'Goal: 52 kg',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL STAT CARDS
  // ============================================================

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _smallStat(
            icon: Icons.trending_down_rounded,
            value: '5 kg',
            label: 'Lost',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _smallStat(
            icon: Icons.flag_outlined,
            value: '50%',
            label: 'Goal',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _smallStat(
            icon: Icons.calendar_today_outlined,
            value: '28',
            label: 'Days',
          ),
        ),
      ],
    );
  }

  Widget _smallStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E3DA)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF27613C), size: 22),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF193A26),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: const TextStyle(color: Color(0xFF777777), fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKLY CHART
  // ============================================================

  Widget _weeklyChart() {
    final weights = [58.4, 58.1, 57.9, 57.7, 57.5, 57.2, 57.0];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E3DA)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF193A26),
                ),
              ),
              Text(
                '-1.4 kg',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(weights.length, (index) {
                final height = 35 + (58.4 - weights[index]) * 35;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      weights[index].toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF777777),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      width: 22,
                      height: height,
                      decoration: BoxDecoration(
                        color: index == weights.length - 1
                            ? const Color(0xFF27613C)
                            : const Color(0xFFDCEBC5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      days[index],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DAILY GOAL CARD
  // ============================================================

  Widget _goalCard({
    required IconData icon,
    required String title,
    required String value,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E3DA)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFE0),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFF27613C), size: 21),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF193A26),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE8EFE0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4E9F3D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOTIVATION CARD
  // ============================================================

  Widget _motivationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFF27613C), size: 24),

          SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep going 🌱',
                  style: TextStyle(
                    color: Color(0xFF193A26),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'You are making progress. Focus on consistency rather than perfection.',
                  style: TextStyle(
                    color: Color(0xFF4D604F),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

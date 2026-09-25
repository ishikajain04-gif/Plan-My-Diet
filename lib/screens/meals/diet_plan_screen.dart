import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DietPlanScreen extends StatelessWidget {
  const DietPlanScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF27613C)),
              );
            }

            final data = snapshot.data ?? {};

            final double calories = (data['dailyCalories'] ?? 0).toDouble();

            final double protein = (data['protein'] ?? 0).toDouble();

            final double carbs = (data['carbohydrates'] ?? 0).toDouble();

            final double fats = (data['fats'] ?? 0).toDouble();

            final String diet =
                data['dietPreference']?.toString() ?? 'Personalized';

            final String goal = data['goal']?.toString() ?? 'Healthy lifestyle';

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),

                  const SizedBox(height: 26),

                  _dateCard(),

                  const SizedBox(height: 18),

                  _nutritionSummary(
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fats: fats,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Today's Meals",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF193A26),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '$diet • Goal: $goal',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 18),

                  _mealCard(
                    time: '08:00',
                    title: 'Breakfast',
                    description: 'Start your day with balanced energy',
                    calories: '450 kcal',
                    icon: Icons.wb_sunny_outlined,
                  ),

                  _mealCard(
                    time: '13:00',
                    title: 'Lunch',
                    description: 'A nourishing and satisfying meal',
                    calories: '620 kcal',
                    icon: Icons.restaurant_outlined,
                  ),

                  _mealCard(
                    time: '17:00',
                    title: 'Snack',
                    description: 'A light boost between meals',
                    calories: '250 kcal',
                    icon: Icons.cookie_outlined,
                  ),

                  _mealCard(
                    time: '20:30',
                    title: 'Dinner',
                    description: 'Finish your day with a balanced plate',
                    calories: '700 kcal',
                    icon: Icons.nightlight_outlined,
                  ),

                  const SizedBox(height: 18),

                  _aiSuggestion(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Diet Plan',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF193A26),
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Your personalized meals for today',
          style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
        ),
      ],
    );
  }

  Widget _dateCard() {
    final now = DateTime.now();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E3DA)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFE0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF27613C),
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: Color(0xFF27613C),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${months[now.month - 1]} ${now.day}, ${now.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF193A26),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutritionSummary({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF245936),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF245936).withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY NUTRITION',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${calories.round()} kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _macro('${protein.round()} g', 'Protein')),
              Expanded(child: _macro('${carbs.round()} g', 'Carbs')),
              Expanded(child: _macro('${fats.round()} g', 'Fats')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macro(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _mealCard({
    required String time,
    required String title,
    required String description,
    required String calories,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E3DA)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFE0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF27613C), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF27613C),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF193A26),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            calories,
            style: const TextStyle(
              color: Color(0xFF193A26),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiSuggestion() {
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
                  'AI Suggestion',
                  style: TextStyle(
                    color: Color(0xFF193A26),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Try to include a protein-rich food with every main meal to stay fuller and support your daily nutrition goal.',
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

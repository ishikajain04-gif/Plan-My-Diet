import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  int selectedIndex = 0;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    if (user == null) {
      throw Exception('User not logged in');
    }

    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  String _getDate() {
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

    return '${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF245936)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load your profile.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Profile not found.'));
            }

            final data = snapshot.data!.data()!;

            final String name = data['name'] ?? 'User';
            final String goal = data['goal'] ?? 'Not set';
            final String diet = data['dietPreference'] ?? 'Not set';

            final double weight = (data['weight'] ?? 0).toDouble();

            final double calories = (data['dailyCalories'] ?? 0).toDouble();

            final double protein = (data['protein'] ?? 0).toDouble();

            final double carbs = (data['carbohydrates'] ?? 0).toDouble();

            final double fats = (data['fats'] ?? 0).toDouble();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 110),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ==================================================
                      // HEADER
                      // ==================================================
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Text(
                                  'Plan My Diet',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF193A26),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.eco_rounded,
                                  color: Color(0xFF72935F),
                                  size: 23,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF193A26),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF285C3A),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // GREETING
                      // ==================================================
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '$name 👋',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF193A26),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${_getDate()}  •  Let’s make today count.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ==================================================
                      // NUTRITION HERO
                      // ==================================================
                      _nutritionHero(
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fats: fats,
                      ),

                      const SizedBox(height: 32),

                      // ==================================================
                      // TODAY'S PLAN
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Today’s Plan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF193A26),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'See all  →',
                              style: TextStyle(
                                color: Color(0xFF285C3A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Your meals for a healthier you',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _mealCard(
                        time: '08:00',
                        title: 'Breakfast',
                        description: 'Your morning fuel',
                        calories: '450 kcal',
                        icon: Icons.wb_sunny_outlined,
                        completed: true,
                      ),

                      _mealCard(
                        time: '13:00',
                        title: 'Lunch',
                        description: 'Balanced & nourishing',
                        calories: '620 kcal',
                        icon: Icons.restaurant_outlined,
                        completed: false,
                      ),

                      _mealCard(
                        time: '17:00',
                        title: 'Snack',
                        description: 'A little boost',
                        calories: '250 kcal',
                        icon: Icons.cookie_outlined,
                        completed: false,
                      ),

                      _mealCard(
                        time: '20:30',
                        title: 'Dinner',
                        description: 'Finish your day well',
                        calories: '700 kcal',
                        icon: Icons.nightlight_outlined,
                        completed: false,
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // HYDRATION + GOAL
                      // ==================================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _hydrationCard()),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _goalCard(
                              goal: goal,
                              diet: diet,
                              weight: weight,
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    // ================================================================
    // BOTTOM NAVIGATION
    // ============================================================
  }

  // ====================================================================
  // NUTRITION HERO
  // ====================================================================

  Widget _nutritionHero({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: const Color(0xFF245936),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF245936).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -80,
            top: -70,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                color: const Color(0xFF376D47).withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -90,
            bottom: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF193F28).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 25,
            child: Icon(
              Icons.eco_rounded,
              size: 75,
              color: const Color(0xFFBFD5A6).withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            right: 55,
            top: 72,
            child: Icon(
              Icons.eco_rounded,
              size: 45,
              color: const Color(0xFFD8E9C0).withValues(alpha: 0.18),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY’S NUTRITION',
                        style: TextStyle(
                          color: const Color(0xFFD4E6BE).withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Your personalized target',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ========================================================
                // CALORIE PROGRESS RING
                // ========================================================
                SizedBox(
                  width: 175,
                  height: 175,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 175,
                        height: 175,
                        child: CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFD9ECA8),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            calories.round().toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'kcal',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Daily Target',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ========================================================
                // MACROS
                // ========================================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _heroMacro(
                          icon: Icons.fitness_center_rounded,
                          value: '${protein.round()} g',
                          label: 'Protein',
                          color: const Color(0xFFF0A497),
                          progress: 0.70,
                        ),
                      ),
                      _verticalDivider(),
                      Expanded(
                        child: _heroMacro(
                          icon: Icons.grass_rounded,
                          value: '${carbs.round()} g',
                          label: 'Carbs',
                          color: const Color(0xFFECCB6C),
                          progress: 0.85,
                        ),
                      ),
                      _verticalDivider(),
                      Expanded(
                        child: _heroMacro(
                          icon: Icons.water_drop_outlined,
                          value: '${fats.round()} g',
                          label: 'Fats',
                          color: const Color(0xFFB7D39C),
                          progress: 0.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMacro({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 55,
      width: 1,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  // ====================================================================
  // MEAL CARD
  // ====================================================================

  Widget _mealCard({
    required String time,
    required String title,
    required String description,
    required String calories,
    required IconData icon,
    required bool completed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Column(
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF285C3A)
                      : const Color(0xFFF8F5ED),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF285C3A), width: 2),
                ),
                child: completed
                    ? const Icon(Icons.check, color: Colors.white, size: 9)
                    : null,
              ),
              Container(width: 1, height: 78, color: Colors.grey.shade300),
            ],
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: const Color(0xFFE8E5DD)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F0E2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: const Color(0xFF285C3A), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    calories,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // HYDRATION
  // ====================================================================

  Widget _hydrationCard() {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFDF),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F5ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: Color(0xFF285C3A),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Hydration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '3 / 8',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF285C3A),
            ),
          ),
          const Text(
            'glasses',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              8,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: index < 3
                          ? const Color(0xFF285C3A)
                          : const Color(0xFFC9D7BE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // GOAL
  // ====================================================================

  Widget _goalCard({
    required String goal,
    required String diet,
    required double weight,
  }) {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E5D2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFF1D0C4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFF8A5A4D),
              size: 21,
            ),
          ),
          const Spacer(),
          const Text(
            'YOUR GOAL',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            goal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF193A26),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$diet • ${weight.toStringAsFixed(1)} kg',
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

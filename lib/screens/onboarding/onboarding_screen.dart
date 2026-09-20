import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    const OnboardingData(
      label: 'PERSONALIZED NUTRITION',
      title: 'Your diet.\nYour way.',
      description:
          'Tell us about yourself and we’ll create a nutrition plan that fits your lifestyle, preferences and goals.',
      bottomText: 'Small steps. Big changes.',
    ),
    const OnboardingData(
      label: 'SMART MEAL PLANNING',
      title: 'Meals that\nfit your life.',
      description:
          'Get personalized meal plans based on your goals, preferences and dietary needs. Simple. Smart. Sustainable.',
      bottomText: 'Healthy food. Happier you.',
    ),
    const OnboardingData(
      label: 'YOUR PROGRESS',
      title: 'See your\nprogress grow.',
      description:
          'Keep track of your meals, nutrition, habits and results — all in one place. Your healthier, happier self is a few steps away.',
      bottomText: 'Better habits. A brighter you.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Row(
                children: [
                  const Text(
                    'Plan My Diet',
                    style: TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF6E9B55),
                    size: 21,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _goToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // PAGES
            // ============================================================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index], pageIndex: index);
                },
              ),
            ),

            // ============================================================
            // INDICATOR
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final active = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 32 : 8,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF27613C)
                        : const Color(0xFFD6DED1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            const SizedBox(height: 18),

            // ============================================================
            // BUTTON
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27613C),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: const Color(
                      0xFF27613C,
                    ).withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 2 ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 21),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _pages[_currentPage].bottomText,
              style: const TextStyle(
                color: Color(0xFF5D8B5A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// DATA
// ==========================================================================

class OnboardingData {
  final String label;
  final String title;
  final String description;
  final String bottomText;

  const OnboardingData({
    required this.label,
    required this.title,
    required this.description,
    required this.bottomText,
  });
}

// ==========================================================================
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int pageIndex;

  const _OnboardingPage({required this.data, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool compact = constraints.maxHeight < 680;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: compact ? 260 : 310,
                    width: double.infinity,
                    child: Center(
                      child: SizedBox(
                        width: width > 700 ? 600 : width - 30,
                        child: _buildVisual(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFE0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      data.label,
                      style: const TextStyle(
                        color: Color(0xFF52735A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF193A26),
                      fontSize: compact ? 30 : 35,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      data.description,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisual() {
    switch (pageIndex) {
      case 0:
        return const _DietVisual();

      case 1:
        return const _MealsVisual();

      case 2:
        return const _ProgressVisual();

      default:
        return const SizedBox();
    }
  }
} // PAGE
// ==========================================================================

// ==========================================================================
// PAGE 1 — DIET
// ==========================================================================

class _DietVisual extends StatelessWidget {
  const _DietVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 35,
          child: Container(
            width: 290,
            height: 245,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE9CC),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),

        Positioned(
          top: 12,
          right: 100,
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0D9),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Plate
        Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            color: const Color(0xFFFDFCF8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 195,
              height: 195,
              decoration: const BoxDecoration(
                color: Color(0xFFE2EBCD),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 28,
                    top: 45,
                    child: _foodCircle(
                      Icons.eco_rounded,
                      const Color(0xFF4F7C46),
                      48,
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 35,
                    child: _foodCircle(
                      Icons.circle,
                      const Color(0xFFC9664C),
                      34,
                    ),
                  ),
                  Positioned(
                    right: 25,
                    bottom: 30,
                    child: Container(
                      width: 75,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E9B4E),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFFDCE8B8),
                        size: 27,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    bottom: 32,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6A477),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Color(0xFF8A5A3B),
                        size: 25,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.spa_rounded,
                    color: Color(0xFF285D3B),
                    size: 48,
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          right: 5,
          top: 75,
          child: _floatingPill(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFE79548),
            title: '1,850 kcal',
            subtitle: 'Daily Goal',
          ),
        ),

        Positioned(
          left: 10,
          bottom: 22,
          child: _floatingPill(
            icon: Icons.eco_rounded,
            iconColor: const Color(0xFF5D8D48),
            title: 'Balanced',
            subtitle: 'Nutrition',
          ),
        ),

        const Positioned(
          left: 5,
          top: 18,
          child: Text(
            'A healthier\nyou starts\nhere. ♡',
            style: TextStyle(
              color: Color(0xFF41694D),
              fontSize: 14,
              height: 1.15,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// PAGE 2 — MEALS
// ==========================================================================

class _MealsVisual extends StatelessWidget {
  const _MealsVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 380,
        height: 350,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 380,
            height: 350,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // =====================================================
                // BACKGROUND SHAPE
                // =====================================================
                Positioned(
                  left: 45,
                  top: 55,
                  child: Container(
                    width: 290,
                    height: 260,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1ECD4),
                      borderRadius: BorderRadius.circular(90),
                    ),
                  ),
                ),

                // =====================================================
                // LEFT LEAF
                // =====================================================
                Positioned(
                  left: 20,
                  top: 215,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 48,
                      color: Color(0xFF5B914A),
                    ),
                  ),
                ),

                // =====================================================
                // RIGHT LEAF
                // =====================================================
                Positioned(
                  right: 25,
                  bottom: 60,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 42,
                      color: Color(0xFF4F8442),
                    ),
                  ),
                ),

                // =====================================================
                // QUOTE
                //
                // IMPORTANT:
                // This is placed above the card and away from it.
                // =====================================================
                Positioned(
                  right: 5,
                  top: 0,
                  child: Container(
                    width: 125,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    color: const Color(0xFFF8F5ED),
                    child: const Text(
                      'Good food\nbrighter mood ☼',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xFF41694D),
                        fontSize: 15,
                        height: 1.1,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

                // =====================================================
                // MAIN MEAL CARD
                // =====================================================
                Positioned(
                  left: 65,
                  top: 45,
                  child: Transform.rotate(
                    angle: -0.035,
                    child: Container(
                      width: 250,
                      height: 300,
                      padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(27),
                        border: Border.all(
                          color: const Color(0xFF193A26),
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.13),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Plan",
                            style: TextStyle(
                              color: Color(0xFF193A26),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Mon', style: TextStyle(fontSize: 8)),
                              Text('Tue', style: TextStyle(fontSize: 8)),
                              Text(
                                'Wed',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Thu', style: TextStyle(fontSize: 8)),
                              Text('Fri', style: TextStyle(fontSize: 8)),
                            ],
                          ),

                          const SizedBox(height: 5),

                          Container(
                            height: 23,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2EDDA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '18',
                              style: TextStyle(
                                color: Color(0xFF27613C),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          _mealRow(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Breakfast',
                            subtitle: 'Oats & Fruits',
                            calories: '320 kcal',
                          ),

                          const SizedBox(height: 4),

                          _mealRow(
                            icon: Icons.restaurant_outlined,
                            title: 'Lunch',
                            subtitle: 'Paneer Quinoa Bowl',
                            calories: '450 kcal',
                          ),

                          const SizedBox(height: 4),

                          _mealRow(
                            icon: Icons.cookie_outlined,
                            title: 'Snack',
                            subtitle: 'Fruit & Nuts',
                            calories: '180 kcal',
                          ),

                          const SizedBox(height: 4),

                          _mealRow(
                            icon: Icons.nightlight_outlined,
                            title: 'Dinner',
                            subtitle: 'Dal Khichdi',
                            calories: '400 kcal',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =====================================================
                // MEALS PILL
                // =====================================================
                Positioned(
                  left: 245,
                  top: 150,
                  child: _featurePill(
                    icon: Icons.restaurant_menu_rounded,
                    iconColor: const Color(0xFF397052),
                    title: 'Meals',
                    subtitle: 'made for you',
                  ),
                ),

                // =====================================================
                // MATCHES PILL
                // =====================================================
                Positioned(
                  left: 250,
                  top: 220,
                  child: _featurePill(
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFE25D63),
                    title: 'Matches',
                    subtitle: 'your goals',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mealRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String calories,
  }) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                color: const Color(0xFFE3ECD9),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: const Color(0xFF316A45), size: 17),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              calories,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _featurePill({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF193A26),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 8),
            ),
          ],
        ),
      ],
    ),
  );
}
// ==========================================================================
// PAGE 3 — PROGRESS
// ==========================================================================

class _ProgressVisual extends StatelessWidget {
  const _ProgressVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 380,
        height: 350,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 380,
            height: 350,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // =====================================================
                // SOFT BACKGROUND
                // =====================================================
                Positioned(
                  left: 45,
                  top: 55,
                  child: Container(
                    width: 290,
                    height: 245,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3ECD4),
                      borderRadius: BorderRadius.circular(90),
                    ),
                  ),
                ),

                // =====================================================
                // DECORATIVE LEAF
                // =====================================================
                Positioned(
                  left: 25,
                  bottom: 60,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 45,
                      color: Color(0xFF5B914A),
                    ),
                  ),
                ),

                Positioned(
                  right: 25,
                  top: 65,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 40,
                      color: Color(0xFF6A9957),
                    ),
                  ),
                ),

                // =====================================================
                // DECORATIVE QUOTE
                // =====================================================
                Positioned(
                  left: 3,
                  top: 0,
                  child: Container(
                    width: 105,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    color: const Color(0xFFF8F5ED),
                    child: const Text(
                      'Track.\nImprove.\nBe proud. ♡',
                      style: TextStyle(
                        color: Color(0xFF41694D),
                        fontSize: 14,
                        height: 1.15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

                // =====================================================
                // MAIN PROGRESS CARD
                // =====================================================
                Positioned(
                  left: 25,
                  top: 38,
                  child: Container(
                    width: 350,
                    height: 250,
                    padding: const EdgeInsets.fromLTRB(18, 15, 18, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.11),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // =============================================
                        // HEADER
                        // =============================================
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Your Progress',
                                style: TextStyle(
                                  color: Color(0xFF193A26),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5EF),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                'This Week⌄',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // =============================================
                        // STATS
                        // =============================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _progressStat(
                              icon: Icons.bar_chart_rounded,
                              label: 'Calories',
                              color: const Color(0xFFE3EED7),
                            ),

                            _progressStat(
                              icon: Icons.fitness_center_rounded,
                              label: 'Protein',
                              color: const Color(0xFFDCEBE6),
                            ),

                            _progressStat(
                              icon: Icons.eco_rounded,
                              label: 'Healthy Habits',
                              color: const Color(0xFFE8EDD5),
                            ),

                            _progressStat(
                              icon: Icons.water_drop_rounded,
                              label: 'Water',
                              color: const Color(0xFFDDECF0),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        // =============================================
                        // GRAPH
                        // =============================================
                        Expanded(
                          child: CustomPaint(
                            painter: _ProgressChartPainter(),
                            child: const SizedBox(width: double.infinity),
                          ),
                        ),

                        // =============================================
                        // DAYS
                        // =============================================
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Mon', style: TextStyle(fontSize: 7)),
                            Text('Tue', style: TextStyle(fontSize: 7)),
                            Text('Wed', style: TextStyle(fontSize: 7)),
                            Text('Thu', style: TextStyle(fontSize: 7)),
                            Text('Fri', style: TextStyle(fontSize: 7)),
                            Text('Sat', style: TextStyle(fontSize: 7)),
                            Text('Sun', style: TextStyle(fontSize: 7)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // =====================================================
                // FLOATING SUCCESS CARD
                // =====================================================
                Positioned(
                  right: 0,
                  top: 185,
                  child: _featurePill(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF5A9A55),
                    title: "You're",
                    subtitle: 'doing great!',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressStat({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF316A45), size: 18),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 7,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// PROGRESS CHART
// ==========================================================================

class _ProgressChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE1E9DC)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(size.width * 0.02, size.height * 0.72),
      Offset(size.width * 0.18, size.height * 0.78),
      Offset(size.width * 0.34, size.height * 0.52),
      Offset(size.width * 0.50, size.height * 0.57),
      Offset(size.width * 0.66, size.height * 0.30),
      Offset(size.width * 0.82, size.height * 0.43),
      Offset(size.width * 0.98, size.height * 0.10),
    ];

    final linePaint = Paint()
      ..color = const Color(0xFF6CA65C)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()..color = const Color(0xFF34704A);

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ==========================================================================
// FLOATING PILL
// ==========================================================================

Widget _floatingPill({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF193A26),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 8),
            ),
          ],
        ),
      ],
    ),
  );
}

// ==========================================================================
// FOOD CIRCLE
// ==========================================================================

Widget _foodCircle(IconData icon, Color color, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Icon(
      icon,
      color: Colors.white.withValues(alpha: 0.85),
      size: size * 0.52,
    ),
  );
}

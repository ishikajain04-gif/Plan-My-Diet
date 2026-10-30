import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../track/track_screen.dart';
import '../home/home_screen.dart';
import '../meals/diet_plan_screen.dart';
import '../profile/profile_screen.dart';
import '../ai/ai_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _showNavigation = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DietPlanScreen(),
    const TrackScreen(),
    const AiScreen(),
    const ProfileScreen(),
  ];

  // ============================================================
  // SHOW / HIDE BOTTOM NAVIGATION WHILE SCROLLING
  // ============================================================

  bool _handleScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      // Scrolling DOWN → hide navigation
      if (notification.direction == ScrollDirection.reverse) {
        if (_showNavigation) {
          setState(() {
            _showNavigation = false;
          });
        }
      }
      // Scrolling UP → show navigation
      else if (notification.direction == ScrollDirection.forward) {
        if (!_showNavigation) {
          setState(() {
            _showNavigation = true;
          });
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),

      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,

        child: Stack(
          children: [
            // ======================================================
            // CURRENT SCREEN
            // ======================================================
            // Positioned.fill(child: _screens[_currentIndex]),
            // KEEP ALL SCREENS ALIVE WHEN SWITCHING TABS
            Positioned.fill(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),

            // ======================================================
            // FLOATING BOTTOM NAVIGATION
            // ======================================================
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,

              left: 0,
              right: 0,

              // Hide by moving below the screen
              bottom: _showNavigation ? 0 : -100,

              child: SafeArea(
                top: false,

                child: Container(
                  margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFF123D27),

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                    children: [
                      _navigationItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                        index: 0,
                      ),

                      _navigationItem(
                        icon: Icons.restaurant_menu_outlined,
                        activeIcon: Icons.restaurant_menu_rounded,
                        label: 'Plan',
                        index: 1,
                      ),

                      _navigationItem(
                        icon: Icons.bar_chart_outlined,
                        activeIcon: Icons.bar_chart_rounded,
                        label: 'Track',
                        index: 2,
                      ),

                      _navigationItem(
                        icon: Icons.auto_awesome_outlined,
                        activeIcon: Icons.auto_awesome,
                        label: 'AI',
                        index: 3,
                      ),

                      _navigationItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profile',
                        index: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _navigationItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool selected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;

          // Always show navigation when user changes screen
          _showNavigation = true;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),

        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCEBC5) : Colors.transparent,

          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              selected ? activeIcon : icon,

              color: selected ? const Color(0xFF193A26) : Colors.white70,

              size: 22,
            ),

            const SizedBox(height: 3),

            Text(
              label,

              style: TextStyle(
                color: selected ? const Color(0xFF193A26) : Colors.white70,

                fontSize: 10,

                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// TEMPORARY TRACK SCREEN
// ================================================================

// ================================================================
// TEMPORARY AI SCREEN
// ================================================================

class _AiPlaceholder extends StatelessWidget {
  const _AiPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('AI Assistant'));
  }
}

// ================================================================
// TEMPORARY PROFILE SCREEN
// ================================================================

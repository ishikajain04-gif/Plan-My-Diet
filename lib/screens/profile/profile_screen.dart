import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user is currently logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF235F3A)),
              );
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;

            final String name =
                data?['name'] ?? currentUser.displayName ?? 'User';

            final String email = data?['email'] ?? currentUser.email ?? '';

            final String initial = name.isNotEmpty
                ? name.trim()[0].toUpperCase()
                : 'U';

            final String age = data?['age'] != null
                ? '${data!['age']} years'
                : 'Not set';

            final String height = data?['height'] != null
                ? '${data!['height']} cm'
                : 'Not set';

            final String weight = data?['weight'] != null
                ? '${data!['weight']} kg'
                : 'Not set';

            final String goal = data?['fitnessGoal'] ?? 'Not set';

            final String dietType = data?['dietType'] ?? 'Not set';

            final String activityLevel = data?['activityLevel'] ?? 'Not set';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF193A26),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Manage your personal information',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 28),

                  // PROFILE HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF235F3A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCEBC5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF193A26),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF193A26),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _infoCard(
                    icon: Icons.cake_outlined,
                    title: 'Age',
                    value: age,
                  ),

                  _infoCard(
                    icon: Icons.height_rounded,
                    title: 'Height',
                    value: height,
                  ),

                  _infoCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weight',
                    value: weight,
                  ),

                  _infoCard(
                    icon: Icons.flag_outlined,
                    title: 'Fitness Goal',
                    value: goal,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Diet Preferences',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF193A26),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _infoCard(
                    icon: Icons.eco_outlined,
                    title: 'Diet Type',
                    value: dietType,
                  ),

                  _infoCard(
                    icon: Icons.directions_run_rounded,
                    title: 'Activity Level',
                    value: activityLevel,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF193A26),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _actionCard(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),

                  _actionCard(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () {},
                  ),

                  _actionCard(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),

                  _actionCard(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E0D7)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0DF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF28633D)),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF193A26),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E0D7)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF28633D)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF193A26),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main/main_navigation_screen.dart';
import '../../services/nutrition_calculator.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _healthConditionsController =
      TextEditingController();

  // Selected answers
  String? _gender;
  String? _activityLevel;
  String? _goal;
  String? _dietPreference;

  final int _totalQuestions = 9;

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _healthConditionsController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!_validateCurrentQuestion()) return;

    if (_currentPage < _totalQuestions - 1) {
      setState(() {
        _currentPage++;
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _saveQuestionnaire();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });

      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentQuestion() {
    String? message;

    switch (_currentPage) {
      case 0:
        if (_ageController.text.trim().isEmpty) {
          message = 'Please enter your age.';
        } else if (int.tryParse(_ageController.text.trim()) == null) {
          message = 'Please enter a valid age.';
        }
        break;

      case 1:
        if (_gender == null) {
          message = 'Please select your gender.';
        }
        break;

      case 2:
        if (_heightController.text.trim().isEmpty) {
          message = 'Please enter your height.';
        } else if (double.tryParse(_heightController.text.trim()) == null) {
          message = 'Please enter a valid height.';
        }
        break;

      case 3:
        if (_weightController.text.trim().isEmpty) {
          message = 'Please enter your weight.';
        } else if (double.tryParse(_weightController.text.trim()) == null) {
          message = 'Please enter a valid weight.';
        }
        break;

      case 4:
        if (_activityLevel == null) {
          message = 'Please select your activity level.';
        }
        break;

      case 5:
        if (_goal == null) {
          message = 'Please select your goal.';
        }
        break;

      case 6:
        if (_dietPreference == null) {
          message = 'Please select your diet preference.';
        }
        break;

      case 7:
        // Allergies are optional.
        break;
    }

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return false;
    }

    return true;
  }

  Future<void> _saveQuestionnaire() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please log in again.')),
      );
      return;
    }

    // Get questionnaire values
    final int? age = int.tryParse(_ageController.text.trim());

    final double? height = double.tryParse(_heightController.text.trim());

    final double? weight = double.tryParse(_weightController.text.trim());

    // Calculate personalized nutrition targets
    final nutrition = NutritionCalculator.calculate(
      age: age!,
      height: height!,
      weight: weight!,
      gender: _gender!,
      activityLevel: _activityLevel!,
      goal: _goal!,
    );

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        // Questionnaire information
        'age': age,
        'height': height,
        'weight': weight,
        'gender': _gender,
        'activityLevel': _activityLevel,
        'goal': _goal,
        'dietPreference': _dietPreference,
        'allergies': _allergiesController.text.trim().isEmpty
            ? 'None'
            : _allergiesController.text.trim(),
        // Personalized nutrition calculations
        'bmr': nutrition.bmr,
        'tdee': nutrition.tdee,
        'dailyCalories': nutrition.dailyCalories,
        'protein': nutrition.protein,
        'carbohydrates': nutrition.carbohydrates,
        'fats': nutrition.fats,

        // Questionnaire status
        'questionnaireCompleted': true,
        'questionnaireCompletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      // Go to dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your information: $e')),
      );
    }
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }

  Widget _optionButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.green.shade600 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: Colors.green.shade600),
          ],
        ),
      ),
    );
  }

  Widget _questionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _genderOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool selected = _gender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EFE0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF27613C) : const Color(0xFFE5E3DA),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.06 : 0.025),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF27613C)
                    : const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF27613C),
                size: 23,
              ),
            ),

            const SizedBox(width: 15),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF27613C) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF27613C)
                      : const Color(0xFFD5D5D0),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool selected = _activityLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activityLevel = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EFE0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF27613C) : const Color(0xFFE5E3DA),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.06 : 0.025),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF27613C)
                    : const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF27613C),
                size: 23,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF27613C) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF27613C)
                      : const Color(0xFFD5D5D0),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool selected = _goal == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _goal = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EFE0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF27613C) : const Color(0xFFE5E3DA),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.06 : 0.025),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF27613C)
                    : const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF27613C),
                size: 23,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF27613C) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF27613C)
                      : const Color(0xFFD5D5D0),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dietOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool selected = _dietPreference == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _dietPreference = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EFE0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF27613C) : const Color(0xFFE5E3DA),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.06 : 0.025),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF27613C)
                    : const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF27613C),
                size: 23,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF27613C) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF27613C)
                      : const Color(0xFFD5D5D0),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(int index) {
    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small section label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 1 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Let's get to know you",
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'A few basic details will help us create '
              'a nutrition plan that feels personal to you.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 34),

            // Age card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E3DA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        color: Color(0xFF27613C),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Your age',
                        style: TextStyle(
                          color: Color(0xFF193A26),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'This helps us estimate your daily nutrition needs.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your age',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      suffixText: 'years',
                      suffixStyle: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F7F1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFF27613C),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Privacy/support note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF27613C),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Your information is used only to personalize '
                      'your Plan My Diet experience.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 2 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'How should we personalize your plan?',
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 31,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'This information helps us make your nutrition '
              'calculations more personalized.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // Gender options
            _genderOption(
              icon: Icons.male_rounded,
              title: 'Male',
              subtitle: 'Personalize using male nutrition estimates',
              value: 'Male',
            ),

            const SizedBox(height: 12),

            _genderOption(
              icon: Icons.female_rounded,
              title: 'Female',
              subtitle: 'Personalize using female nutrition estimates',
              value: 'Female',
            ),

            const SizedBox(height: 12),

            _genderOption(
              icon: Icons.transgender_rounded,
              title: 'Other',
              subtitle: 'Choose another gender identity',
              value: 'Other',
            ),

            const SizedBox(height: 12),

            _genderOption(
              icon: Icons.favorite_border_rounded,
              title: 'Prefer not to say',
              subtitle: 'You can keep this information private',
              value: 'Prefer not to say',
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 3 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "What's your height?",
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Your height helps us understand your body '
              'measurements and calculate your nutrition needs.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Height measurement card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E3DA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Measurement icon
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFE0),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.height_rounded,
                      color: Color(0xFF27613C),
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Height',
                    style: TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Enter your height in centimeters',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: '170',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                      suffixText: 'cm',
                      suffixStyle: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F7F1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: Color(0xFF27613C),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Helpful note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF27613C),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'For the most accurate result, enter your '
                      'height without shoes.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 4 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "What's your weight?",
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Your current weight helps us calculate your '
              'nutrition targets and track your progress.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E3DA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFE0),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: Color(0xFF27613C),
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Current weight',
                    style: TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Enter your weight in kilograms',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: '60',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                      suffixText: 'kg',
                      suffixStyle: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F7F1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: Color(0xFF27613C),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFF27613C),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Use your current weight for the most '
                      'accurate nutrition recommendations.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 5 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'How active are you?',
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Choose the option that best describes your usual '
              'daily activity and exercise routine.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            _activityOption(
              icon: Icons.event_seat_rounded,
              title: 'Sedentary',
              subtitle: 'Little to no regular exercise',
              value: 'Sedentary',
            ),

            const SizedBox(height: 12),

            _activityOption(
              icon: Icons.directions_walk_rounded,
              title: 'Lightly Active',
              subtitle: 'Light exercise or walking 1–3 days/week',
              value: 'Lightly Active',
            ),

            const SizedBox(height: 12),

            _activityOption(
              icon: Icons.directions_run_rounded,
              title: 'Moderately Active',
              subtitle: 'Moderate exercise 3–5 days/week',
              value: 'Moderately Active',
            ),

            const SizedBox(height: 12),

            _activityOption(
              icon: Icons.fitness_center_rounded,
              title: 'Very Active',
              subtitle: 'Hard exercise or intense activity 6–7 days/week',
              value: 'Very Active',
            ),

            const SizedBox(height: 18),

            // Helpful note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    color: Color(0xFF27613C),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Choose the option that matches your normal '
                      'routine, not an unusually active day.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 6 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "What's your goal?",
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Tell us what you want to achieve so we can '
              'shape your nutrition plan around it.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            _goalOption(
              icon: Icons.trending_down_rounded,
              title: 'Lose Weight',
              subtitle:
                  'A balanced calorie-controlled plan for weight management',
              value: 'Lose Weight',
            ),

            const SizedBox(height: 12),

            _goalOption(
              icon: Icons.balance_rounded,
              title: 'Maintain Weight',
              subtitle:
                  'Keep your current weight with balanced daily nutrition',
              value: 'Maintain Weight',
            ),

            const SizedBox(height: 12),

            _goalOption(
              icon: Icons.trending_up_rounded,
              title: 'Gain Weight',
              subtitle: 'A higher-energy plan to support healthy weight gain',
              value: 'Gain Weight',
            ),

            const SizedBox(height: 12),

            _goalOption(
              icon: Icons.fitness_center_rounded,
              title: 'Build Muscle',
              subtitle:
                  'Protein-focused nutrition to support muscle development',
              value: 'Build Muscle',
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    color: Color(0xFF27613C),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Your goal will influence your daily calorie '
                      'and nutrition targets.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 7 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'What do you prefer to eat?',
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Choose the eating style that best matches '
              'your everyday food preferences.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            _dietOption(
              icon: Icons.eco_rounded,
              title: 'Vegetarian',
              subtitle:
                  'Plant-based foods with dairy and other vegetarian options',
              value: 'Vegetarian',
            ),

            const SizedBox(height: 12),

            _dietOption(
              icon: Icons.restaurant_rounded,
              title: 'Non-Vegetarian',
              subtitle: 'Includes meat, poultry or seafood',
              value: 'Non-Vegetarian',
            ),

            const SizedBox(height: 12),

            _dietOption(
              icon: Icons.spa_rounded,
              title: 'Vegan',
              subtitle: 'Fully plant-based food choices',
              value: 'Vegan',
            ),

            const SizedBox(height: 12),

            _dietOption(
              icon: Icons.egg_alt_rounded,
              title: 'Eggetarian',
              subtitle: 'Vegetarian foods with eggs',
              value: 'Eggetarian',
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Color(0xFF27613C),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Your preference will be used when selecting '
                      'foods and creating your meal recommendations.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 7:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 8 OF 8',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Any allergies or restrictions?',
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Tell us about foods you cannot eat or prefer '
              'to avoid so we can keep your recommendations safe.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // Allergy input card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E3DA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EFE0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_outlined,
                          color: Color(0xFF27613C),
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food allergies & restrictions',
                              style: TextStyle(
                                color: Color(0xFF193A26),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Optional',
                              style: TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _allergiesController,
                    keyboardType: TextInputType.text,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: Color(0xFF193A26),
                      fontSize: 15,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. peanuts, lactose, shellfish...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F7F1),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: Color(0xFF27613C),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Safety note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF27613C),
                    size: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Mention any food allergies or important '
                      'restrictions. You can leave this blank if none apply.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 8:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'STEP 9 OF 9',
                style: TextStyle(
                  color: Color(0xFF27613C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Any health conditions we should know about?',
              style: TextStyle(
                color: Color(0xFF193A26),
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Share any relevant health conditions or dietary '
              'instructions so the assistant can tailor its general '
              'food suggestions more carefully.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _healthConditionsController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Color(0xFF193A26), fontSize: 15),
              decoration: InputDecoration(
                hintText: 'e.g. diabetes, high blood pressure, or none',
                filled: true,
                fillColor: const Color(0xFFF8F7F1),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: Color(0xFF27613C),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFE0).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Text(
                'Optional. Your AI assistant provides general '
                'nutrition information, not medical diagnosis or '
                'treatment advice.',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _totalQuestions - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 48),

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Personalize Your Plan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / _totalQuestions,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Question
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _totalQuestions,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                    child: _buildQuestion(index),
                  );
                },
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLastPage ? 'Create My Plan' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

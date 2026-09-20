import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';
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

  // Selected answers
  String? _gender;
  String? _activityLevel;
  String? _goal;
  String? _dietPreference;

  final int _totalQuestions = 8;

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
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

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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

      // Close loading dialog
      Navigator.of(context).pop();

      // Go to dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

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

  Widget _buildQuestion(int index) {
    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: "What's your age?",
              subtitle: 'Your age helps us personalize your nutrition plan.',
            ),
            _textField(
              controller: _ageController,
              hintText: 'Enter your age',
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: "What's your gender?",
              subtitle:
                  'This helps us make more accurate nutrition calculations.',
            ),
            _optionButton(
              title: 'Male',
              selected: _gender == 'Male',
              onTap: () => setState(() => _gender = 'Male'),
            ),
            _optionButton(
              title: 'Female',
              selected: _gender == 'Female',
              onTap: () => setState(() => _gender = 'Female'),
            ),
            _optionButton(
              title: 'Other',
              selected: _gender == 'Other',
              onTap: () => setState(() => _gender = 'Other'),
            ),
            _optionButton(
              title: 'Prefer not to say',
              selected: _gender == 'Prefer not to say',
              onTap: () => setState(() => _gender = 'Prefer not to say'),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: "What's your height?",
              subtitle: 'Enter your height in centimeters.',
            ),
            _textField(
              controller: _heightController,
              hintText: 'Height in cm',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: "What's your weight?",
              subtitle: 'Enter your current weight in kilograms.',
            ),
            _textField(
              controller: _weightController,
              hintText: 'Weight in kg',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        );

      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: 'How active are you?',
              subtitle:
                  'Choose the option that best describes your usual activity.',
            ),
            _optionButton(
              title: 'Sedentary',
              selected: _activityLevel == 'Sedentary',
              onTap: () => setState(() => _activityLevel = 'Sedentary'),
            ),
            _optionButton(
              title: 'Lightly Active',
              selected: _activityLevel == 'Lightly Active',
              onTap: () => setState(() => _activityLevel = 'Lightly Active'),
            ),
            _optionButton(
              title: 'Moderately Active',
              selected: _activityLevel == 'Moderately Active',
              onTap: () => setState(() => _activityLevel = 'Moderately Active'),
            ),
            _optionButton(
              title: 'Very Active',
              selected: _activityLevel == 'Very Active',
              onTap: () => setState(() => _activityLevel = 'Very Active'),
            ),
          ],
        );

      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: "What's your goal?",
              subtitle: 'Your goal helps us create a suitable nutrition plan.',
            ),
            _optionButton(
              title: 'Lose Weight',
              selected: _goal == 'Lose Weight',
              onTap: () => setState(() => _goal = 'Lose Weight'),
            ),
            _optionButton(
              title: 'Maintain Weight',
              selected: _goal == 'Maintain Weight',
              onTap: () => setState(() => _goal = 'Maintain Weight'),
            ),
            _optionButton(
              title: 'Gain Weight',
              selected: _goal == 'Gain Weight',
              onTap: () => setState(() => _goal = 'Gain Weight'),
            ),
            _optionButton(
              title: 'Build Muscle',
              selected: _goal == 'Build Muscle',
              onTap: () => setState(() => _goal = 'Build Muscle'),
            ),
          ],
        );

      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: "What's your diet preference?",
              subtitle: 'Choose the type of diet you usually follow.',
            ),
            _optionButton(
              title: 'Vegetarian',
              selected: _dietPreference == 'Vegetarian',
              onTap: () => setState(() => _dietPreference = 'Vegetarian'),
            ),
            _optionButton(
              title: 'Non-Vegetarian',
              selected: _dietPreference == 'Non-Vegetarian',
              onTap: () => setState(() => _dietPreference = 'Non-Vegetarian'),
            ),
            _optionButton(
              title: 'Vegan',
              selected: _dietPreference == 'Vegan',
              onTap: () => setState(() => _dietPreference = 'Vegan'),
            ),
            _optionButton(
              title: 'Eggetarian',
              selected: _dietPreference == 'Eggetarian',
              onTap: () => setState(() => _dietPreference = 'Eggetarian'),
            ),
          ],
        );

      case 7:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionTitle(
              title: 'Any allergies or restrictions?',
              subtitle:
                  'Tell us about foods you cannot or prefer not to eat. This is optional.',
            ),
            _textField(
              controller: _allergiesController,
              hintText: 'e.g. Peanuts, lactose',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            Text(
              'You can write "None" if you have no restrictions.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  String? _gender;
  String? _activityLevel;
  String? _goal;
  String? _dietPreference;

  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestionnaire() async {
    final age = _ageController.text.trim();
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    final allergies = _allergiesController.text.trim();

    // Validation
    if (age.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        _gender == null ||
        _activityLevel == null ||
        _goal == null ||
        _dietPreference == null) {
      _showMessage('Please complete all required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage('Please login again.');
        return;
      }

      // Save questionnaire data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'age': int.tryParse(age),
        'height': double.tryParse(height),
        'weight': double.tryParse(weight),
        'gender': _gender,
        'activityLevel': _activityLevel,
        'goal': _goal,
        'dietPreference': _dietPreference,
        'allergies': allergies.isEmpty ? 'None' : allergies,
        'questionnaireCompleted': true,
        'questionnaireCompletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      // Go to dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseException catch (e) {
      if (mounted) {
        _showMessage(e.message ?? 'Unable to save your information.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF263326),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1E5128)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF263326),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E5128),
        title: const Text(
          'Your Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about yourself 🌱',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E5128),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'This helps us create a diet plan personalized for you.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF667566),
                ),
              ),

              const SizedBox(height: 32),

              _buildTextField(
                label: 'Age',
                hint: 'Enter your age',
                controller: _ageController,
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Gender',
                hint: 'Select your gender',
                value: _gender,
                items: const ['Female', 'Male', 'Other', 'Prefer not to say'],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Height',
                      hint: 'cm',
                      controller: _heightController,
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      label: 'Weight',
                      hint: 'kg',
                      controller: _weightController,
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Activity Level',
                hint: 'How active are you?',
                value: _activityLevel,
                items: const [
                  'Sedentary',
                  'Lightly Active',
                  'Moderately Active',
                  'Very Active',
                  'Extremely Active',
                ],
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Your Goal',
                hint: 'What is your main goal?',
                value: _goal,
                items: const [
                  'Lose Weight',
                  'Maintain Weight',
                  'Gain Weight',
                  'Build Muscle',
                ],
                onChanged: (value) {
                  setState(() {
                    _goal = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Diet Preference',
                hint: 'Choose your diet type',
                value: _dietPreference,
                items: const [
                  'Vegetarian',
                  'Vegan',
                  'Eggetarian',
                  'Non-Vegetarian',
                ],
                onChanged: (value) {
                  setState(() {
                    _dietPreference = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildTextField(
                label: 'Food Allergies / Restrictions',
                hint: 'Example: peanuts, lactose, none',
                controller: _allergiesController,
                icon: Icons.no_food_outlined,
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveQuestionnaire,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5128),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF1E5128,
                    ).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

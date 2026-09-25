import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main/main_navigation_screen.dart';

import '../questionnaire/questionnaire_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user == null) {
        _showMessage('Unable to login. Please try again.');
        return;
      }

      // 2. Get Firestore profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // 3. Create profile if it doesn't exist
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? email,
          'questionnaireCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
        );

        return;
      }

      // 4. Check questionnaire status
      final data = userDoc.data();

      final bool questionnaireCompleted =
          data?['questionnaireCompleted'] == true;

      if (!mounted) return;

      // 5. Navigate
      if (questionnaireCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      if (mounted) {
        _showMessage(message);
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

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 850;

            if (isDesktop) {
              return _desktopLayout();
            }

            return _mobileLayout();
          },
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP LAYOUT
  // ============================================================

  Widget _desktopLayout() {
    return Row(
      children: [
        // ========================================================
        // LEFT VISUAL
        // ========================================================
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEDC),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  left: -90,
                  bottom: -80,
                  child: _decorativeCircle(
                    size: 260,
                    color: const Color(0xFFD4E4C6),
                  ),
                ),

                Positioned(
                  right: -70,
                  top: -70,
                  child: _decorativeCircle(
                    size: 230,
                    color: const Color(0xFFD1E0C2),
                  ),
                ),

                // Logo
                Positioned(left: 32, top: 28, child: _logo()),

                // Main visual
                Center(child: _loginIllustration(large: true)),

                // Bottom message
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: 38,
                  child: Column(
                    children: [
                      const Text(
                        'Eat better. Feel better.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF193A26),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Your personalized nutrition journey starts here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ========================================================
        // RIGHT FORM
        // ========================================================
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 35),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: _loginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE LAYOUT
  // ============================================================

  Widget _mobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 35),
      child: Column(
        children: [
          // Logo
          Row(
            children: [
              _logo(),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFF27613C),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Small illustration
          SizedBox(height: 190, child: _loginIllustration(large: false)),

          const SizedBox(height: 8),

          _loginForm(),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _logo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Plan My Diet',
          style: TextStyle(
            color: Color(0xFF193A26),
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 5),
        const Icon(Icons.eco_rounded, color: Color(0xFF6A9957), size: 21),
      ],
    );
  }

  // ============================================================
  // LOGIN ILLUSTRATION
  // ============================================================

  Widget _loginIllustration({required bool large}) {
    final double size = large ? 310 : 190;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main green rounded card
          Container(
            width: size * 0.62,
            height: size * 0.78,
            decoration: BoxDecoration(
              color: const Color(0xFF27613C),
              borderRadius: BorderRadius.circular(size * 0.13),
            ),
          ),

          // Soft circle
          Positioned(
            top: size * 0.18,
            child: Container(
              width: size * 0.53,
              height: size * 0.53,
              decoration: BoxDecoration(
                color: const Color(0xFFE2EED4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF8F5ED),
                  width: size * 0.035,
                ),
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: const Color(0xFF27613C),
                size: size * 0.20,
              ),
            ),
          ),

          // Top pill
          Positioned(
            top: size * 0.08,
            right: size * 0.03,
            child: _visualPill(icon: Icons.eco_rounded, text: 'Healthy'),
          ),

          // Bottom pill
          Positioned(
            bottom: size * 0.10,
            left: size * 0.01,
            child: _visualPill(
              icon: Icons.check_circle_rounded,
              text: 'Personalized',
            ),
          ),

          // Decorative leaf
          Positioned(
            bottom: size * 0.05,
            right: size * 0.10,
            child: Transform.rotate(
              angle: 0.5,
              child: Icon(
                Icons.eco_rounded,
                size: size * 0.14,
                color: const Color(0xFFD5E6C2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VISUAL PILL
  // ============================================================

  Widget _visualPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF27613C), size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF193A26),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN FORM
  // ============================================================

  Widget _loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------------
        // HEADING
        // --------------------------------------------------------
        const Text(
          'Welcome back! 👋',
          style: TextStyle(
            color: Color(0xFF193A26),
            fontSize: 32,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Continue your healthy journey.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 30),

        // --------------------------------------------------------
        // EMAIL
        // --------------------------------------------------------
        const Text(
          'Email',
          style: TextStyle(
            color: Color(0xFF303530),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        _inputField(
          controller: _emailController,
          hint: 'Enter your email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 18),

        // --------------------------------------------------------
        // PASSWORD
        // --------------------------------------------------------
        const Text(
          'Password',
          style: TextStyle(
            color: Color(0xFF303530),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        _inputField(
          controller: _passwordController,
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffix: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),

        const SizedBox(height: 9),

        // --------------------------------------------------------
        // FORGOT PASSWORD
        // --------------------------------------------------------
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Forgot password will be connected later.
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: Color(0xFF27613C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // --------------------------------------------------------
        // LOGIN BUTTON
        // --------------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27613C),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(
                0xFF27613C,
              ).withValues(alpha: 0.55),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 9),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 27),

        // --------------------------------------------------------
        // OR
        // --------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: const Color(0xFFD8D8D0)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Text(
                'or',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: const Color(0xFFD8D8D0)),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // --------------------------------------------------------
        // SIGN UP
        // --------------------------------------------------------
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Color(0xFF777777), fontSize: 13),
                children: [
                  TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF27613C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5E3DA)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFF303530), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF52735A), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DECORATIVE CIRCLE
  // ============================================================

  Widget _decorativeCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

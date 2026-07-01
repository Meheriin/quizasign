import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quizasign/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        String errorMsg = e.toString();
        if (errorMsg.contains('email-already-in-use')) {
          _showMessage("This email was used previously. Please use another or login.");
        } else {
          _showMessage("Sign up failed. Please check your connection.");
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4776E6);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New Explorer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            right: -50,
            child: FadeInUp(
              child: Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              child: const Text('Start Your Journey', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E))),
                            ),
                            const SizedBox(height: 10),
                            FadeInUp(
                              delay: const Duration(milliseconds: 100),
                              child: Text('Create a MindLoom account to track your wisdom.', style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(height: 40),
                            _buildInputField(
                              controller: _nameController,
                              label: 'Explorer Name',
                              hint: 'Enter your full name',
                              icon: Icons.person_outline_rounded,
                              validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null,
                            ),
                            const SizedBox(height: 25),
                            _buildInputField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Enter your email',
                              icon: Icons.alternate_email_rounded,
                              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 25),
                            _buildInputField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Create a password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureText,
                              suffix: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey[400]),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ chars' : null,
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              width: double.infinity,
                              height: 65,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signUp,
                                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Begin Adventure'),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already a Weaver? ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Sign In', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required String hint, required IconData icon, bool obscureText = false, Widget? suffix, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E), fontSize: 14)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF9FAFF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFF4776E6), width: 2)),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}

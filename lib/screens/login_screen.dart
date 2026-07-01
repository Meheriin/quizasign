import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quizasign/services/auth_service.dart';
import 'package:quizasign/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          );
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
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -50,
            left: -50,
            child: FadeInDown(
              child: Container(width: 250, height: 250, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle)),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
                    child: const Icon(Icons.psychology_rounded, size: 60, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: const Text('MindLoom', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                ),
                const SizedBox(height: 50),
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
                            const Text('Elevate Your Mind', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E1E1E))),
                            const SizedBox(height: 10),
                            Text('Please login to continue your journey.', style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 40),
                            _buildInputField(
                              controller: _emailController,
                              label: 'Knowledge Hub ID (Email)',
                              hint: 'Enter your email',
                              icon: Icons.alternate_email_rounded,
                              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 25),
                            _buildInputField(
                              controller: _passwordController,
                              label: 'Mind Vault Code (Password)',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureText,
                              suffix: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey[400]),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ chars' : null,
                            ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Forgot Key?', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(height: 35),
                            SizedBox(
                              width: double.infinity,
                              height: 65,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Unlock MindLoom'),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(child: Text('OR CONNECT VIA', style: TextStyle(color: Colors.grey[300], fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2))),
                            const SizedBox(height: 30),
                            _buildGoogleButton(),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("New Explorer? ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                                  child: const Text('Create Account', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFF7455F7), width: 2)),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return InkWell(
      onTap: () async {
        setState(() => _isLoading = true);
        final user = await _authService.signInWithGoogle();
        setState(() => _isLoading = false);
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        height: 65,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.withOpacity(0.1), width: 2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 40),
            const SizedBox(width: 10),
            const Text('Google Account', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

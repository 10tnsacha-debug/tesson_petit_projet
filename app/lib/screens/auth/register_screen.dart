import 'package:flutter/material.dart';
import 'package:formation_flutter/api/auth_api.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authApi = AuthApi();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> register() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await authApi.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      await authApi.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      setState(() {
        errorMessage = 'Impossible de créer le compte.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: SizedBox(
          width: 375,
          height: 812,
          child: Stack(
            children: [
              // Titre "Inscription"
              const Positioned(
                left: 140,
                top: 265,
                child: SizedBox(
                  width: 93,
                  height: 27,
                  child: Text(
                    'Inscription',
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 27 / 20,
                      letterSpacing: -0.48,
                      color: Color(0xFF080040),
                    ),
                  ),
                ),
              ),

              // Champ email
              Positioned(
                left: 12,
                top: 371,
                child: _AuthInputField(
                  controller: emailController,
                  hintText: 'Adresse email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              // Champ mot de passe
              Positioned(
                left: 12,
                top: 429,
                child: _AuthInputField(
                  controller: passwordController,
                  hintText: 'Mot de passe',
                  icon: Icons.lock,
                  obscureText: true,
                ),
              ),

              // Bouton
              Positioned(
                left: 89,
                top: 503,
                child: _AuthYellowButton(
                  label: "S'inscrire",
                  isLoading: isLoading,
                  onPressed: register,
                ),
              ),

              if (errorMessage.isNotEmpty)
                Positioned(
                  left: 12,
                  top: 560,
                  width: 351,
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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

class _AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const _AuthInputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 351,
      height: 44,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF080040),
        style: const TextStyle(
          fontFamily: 'Avenir',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 20 / 15,
          color: Color(0xFF080040),
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 20 / 15,
            color: Color(0xFF6A6A6A),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 10),
            child: Icon(icon, size: 20, color: const Color(0xFF080040)),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 44,
          ),
          contentPadding: const EdgeInsets.only(
            left: 0,
            right: 16,
            top: 12,
            bottom: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFB8BBC6), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFB8BBC6), width: 1),
          ),
        ),
      ),
    );
  }
}

class _AuthYellowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _AuthYellowButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 197,
      height: 45,
      child: Material(
        color: const Color(0xFFFBAF02),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF080040),
                              ),
                            ),
                          )
                        : Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 20 / 15,
                              color: Color(0xFF080040),
                            ),
                          ),
                  ),
                ),
                if (!isLoading)
                  const Icon(
                    Icons.arrow_forward,
                    size: 22,
                    color: Color(0xFF080040),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

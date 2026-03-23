import 'package:flutter/material.dart';
import 'package:formation_flutter/api/auth_api.dart';
import 'package:formation_flutter/screens/auth/widgets/auth_text_field.dart';
import 'package:formation_flutter/screens/auth/widgets/auth_yellow_button.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthApi authApi = AuthApi();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await authApi.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      print('ERREUR CONNEXION COMPLETE: $e');
      setState(() {
        errorMessage = 'Email ou mot de passe incorrect.';
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
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: SizedBox(
                      width: 375,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 24),
                          const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF17135C),
                            ),
                          ),
                          const SizedBox(height: 40),
                          AuthTextField(
                            controller: emailController,
                            hintText: 'Adresse email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            controller: passwordController,
                            hintText: 'Mot de passe',
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                          const SizedBox(height: 23),
                          AuthYellowButton(
                            label: 'Créer un compte',
                            onPressed: () => context.go('/register'),
                          ),
                          const SizedBox(height: 14),
                          AuthYellowButton(
                            label: 'Se connecter',
                            onPressed: isLoading ? null : login,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 12),
                          if (errorMessage.isNotEmpty)
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/components/auth_header.dart';
import 'package:learning_management_system/components/auth_text_field.dart';
import 'package:learning_management_system/widgets/custom_button.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/utils/verification_helper.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';

/// Screen for handling user sign-in functionality.
/// 
/// Uses [AuthService] for authentication and [VerificationHelper] for email verification.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(authProvider.notifier).handleSignIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response['success']) {
        final authState = ref.read(authProvider);
        if (authState.hasError) {
          throw authState.error!;
        }
        
        if (authState.hasValue && authState.value != null) {
          context.goNamed(Routes.homeName);
        } else {
          throw Exception('Failed to authenticate user');
        }
      } else if (response['needs_verification']) {
        final verificationSuccess = await VerificationHelper.handleVerification(
          context: context,
          email: _emailController.text,
          verificationCode: response['verify_code'] as String,
        );

        if (verificationSuccess) {
          await _handleSignInAfterVerification();
        }
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error in _handleSignIn: ${e.toString()}');
      
      String errorMessage = 'An unexpected error occurred';
      Color backgroundColor = const Color.fromARGB(255, 255, 21, 0);
      
      if (e is ApiException) {
        if (e.message.contains('email not existed')) {
          errorMessage = 'This email is not registered. Please sign up first.';
        } else if (e.message.contains('password is incorrect')) {
          errorMessage = 'The password you entered is incorrect. Please try again.';
        } else {
          errorMessage = e.message;
        }
        debugPrint('ApiException details: ${e.data}');
      } else if (e is NetworkException) {
        errorMessage = e.message;
        debugPrint('NetworkException: ${e.message}');
      } else {
        errorMessage = e.toString();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SelectableText.rich(
            TextSpan(
              text: errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignInAfterVerification() async {
    try {
      final success = await ref.read(authProvider.notifier)
          .handleSignInAfterVerification(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      
      if (success) {
        context.goNamed(Routes.homeName);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back, 
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 16.0),
              const AuthHeader(title: 'Welcome Back to AllHust'),
              const SizedBox(height: 32.0),
              _buildSignInForm(),
              const SizedBox(height: 24.0),
              CustomButton(
                text: 'SIGN IN',
                onPressed: _handleSignIn,
                isLoading: _isLoading,
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                textColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        debugPrint('Navigating to signup screen');
                        context.goNamed(Routes.signupName);
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _emailController,
            labelText: 'Email',
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16.0),
          AuthTextField(
            controller: _passwordController,
            labelText: 'Password',
            validator: _validatePassword,
            obscureText: _obscureText,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSignIn(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password logic here
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
}

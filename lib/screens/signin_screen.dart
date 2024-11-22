import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/components/auth_header.dart';
import 'package:learning_management_system/components/auth_text_field.dart';
import 'package:learning_management_system/widgets/custom_button.dart';
import 'package:learning_management_system/services/auth_service.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/utils/verification_helper.dart';
import 'package:learning_management_system/models/user.dart';

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
      final authService = ref.read(authServiceProvider);
      final result = await authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['needs_verification'] == true) {
        final verificationSuccess = await VerificationHelper.handleVerification(
          context: context,
          email: _emailController.text,
          verificationCode: result['verify_code'],
        );

        if (!mounted) return;

        if (verificationSuccess) {
          await _handleSignInAfterVerification();
          return;
        }
      }

      if (result['token'] != null) {
        final user = User.fromJson(result['user'] as Map<String, dynamic>);
        await ref.read(authProvider.notifier).signIn(
          user,
          result['token'] as String,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignInAfterVerification() async {
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['token'] != null) {
        final user = User.fromJson(result['user'] as Map<String, dynamic>);
        await ref.read(authProvider.notifier).signIn(
          user,
          result['token'] as String,
        );
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon:
                    Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
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
                backgroundColor: theme.colorScheme.onPrimary,
                textColor: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16.0),
              _buildSignUpLink(),
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

  Widget _buildSignUpLink() {
    return Center(
      child: TextButton(
        onPressed: () => context.push(Routes.signup),
        child: Text(
          'Create a new account',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
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

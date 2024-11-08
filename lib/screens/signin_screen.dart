import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/components/auth_header.dart';
import 'package:learning_management_system/components/auth_text_field.dart';
import 'package:learning_management_system/widgets/custom_button.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/auth_service.dart';
import 'package:learning_management_system/routes/routes.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingToken();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingToken() async {
    final authState = await ref.read(authProvider.future);
    if (authState != null) {
      if (!mounted) return;
      _redirectBasedOnRole(authState.role);
    }
  }

  void _redirectBasedOnRole(String role) {
    if (role.toUpperCase() == 'LECTURER') {
      context.go(Routes.teacherHome);
    } else if (role.toUpperCase() == 'STUDENT') {
      context.go(Routes.studentHome);
    }
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final result = await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        final token = user.token;

        // Save token and update user state
        await ref.read(authProvider.notifier).login(user, token);

        if (!mounted) return;
        _redirectBasedOnRole(user.role);
      } else if (result['needs_verification'] == true) {
        if (!mounted) return;
        context.go(
          Routes.signin,
          extra: {
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );
      } else {
        throw Exception('Login failed');
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
    return Column(
      children: [
        AuthTextField(
          controller: _emailController,
          labelText: 'Email',
        ),
        const SizedBox(height: 16.0),
        AuthTextField(
          controller: _passwordController,
          labelText: 'Password',
          obscureText: _obscureText,
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
}

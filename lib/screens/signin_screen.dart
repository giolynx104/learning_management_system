import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/routes/app_routes.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/components/auth_header.dart';
import 'package:learning_management_system/components/auth_text_field.dart';
import 'package:learning_management_system/widgets/custom_button.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/auth_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storageService = StorageService();
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
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        final role = await _storageService.getUserRole();
        if (role != null) {
          if (!mounted) return;
          _redirectBasedOnRole(role);
        }
      }
    } catch (e) {
      debugPrint('Error checking token: $e');
    }
  }

  void _redirectBasedOnRole(String role) {
    if (role.toUpperCase() == 'LECTURER') {
      Navigator.pushReplacementNamed(context, AppRoutes.teacherHome);
    } else if (role.toUpperCase() == 'STUDENT') {
      Navigator.pushReplacementNamed(context, AppRoutes.studentHome);
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
        final user = result['user'] as User;
        
        await _storageService.saveUserSession(
          token: user.token,
          role: user.role,
          userId: user.id,
        );

        ref.read(userProvider.notifier).state = user;

        if (!mounted) return;
        _redirectBasedOnRole(user.role);
      } else if (result['needs_verification'] == true) {
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          AppRoutes.signin,
          arguments: {
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
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
                onPressed: () {
                  Navigator.pop(context);
                },
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
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.signup);
        },
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

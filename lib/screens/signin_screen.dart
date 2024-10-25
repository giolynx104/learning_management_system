import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/routes/app_routes.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/components/auth_header.dart';
import 'package:learning_management_system/components/auth_text_field.dart';
import 'package:learning_management_system/widgets/custom_button.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/models/user.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storageService = StorageService();
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
    final token = await _storageService.getToken();
    if (token != null) {
      final user = await _getUserFromToken(token);
      if (user != null) {
        _redirectToHome(user);
      }
    }
  }

  Future<User?> _getUserFromToken(String token) async {
    // TODO: Implement a method to get user details from the token
    return User(
      id: 1,
      username: 'dummyuser@example.com',
      token: token,
      active: 'Active',
      role: 'STUDENT',
      classList: ['Dummy Class'],
    );
  }

  void _redirectToHome(User user) {
    ref.read(userProvider.notifier).state = user;
    if (user.role.toLowerCase() == 'teacher') {
      Navigator.pushReplacementNamed(context, AppRoutes.teacherHome);
    } else if (user.role.toLowerCase() == 'student') {
      Navigator.pushReplacementNamed(context, AppRoutes.studentHome);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final loginData = {
      'email': _emailController.text,
      'password': _passwordController.text,
      'deviceId': 1, // You might want to generate this dynamically
    };

    try {
      final user = await ref.read(loginProvider(loginData).future);
      if (!mounted) return;
      
      ref.read(userProvider.notifier).state = user;
      await _storageService.saveToken(user.token);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      _redirectToHome(user);
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'An unexpected error occurred. Please try again later.';
      if (e is Exception) {
        if (e.toString().contains('User not found or wrong password')) {
          errorMessage = 'Invalid email or password. Please check your credentials and try again.';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          'Create new account',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

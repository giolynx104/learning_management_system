import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/routes/app_routes.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'dart:io';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/models/user.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final emailFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingToken();
      FocusScope.of(context).requestFocus(emailFocusNode);
    });
  }

  Future<void> _checkExistingToken() async {
    final token = await _storageService.getToken();
    if (token != null) {
      // TODO: Validate the token with the server
      // For now, we'll assume it's valid and redirect to the home page
      // In a real app, you should verify the token with your server
      final user = await _getUserFromToken(token);
      if (user != null) {
        _redirectToHome(user);
      }
    }
  }

  Future<User?> _getUserFromToken(String token) async {
    // TODO: Implement a method to get user details from the token
    // This might involve making an API call to your server
    // For now, we'll return a dummy user
    return User(
      id: 1,
      username: 'dummyuser@example.com',
      token: token,
      active: 'Active',
      role: 'STUDENT', // or 'TEACHER' based on your app's logic
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

  @override
  void dispose() {
    emailFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;
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
      
      // Store the user data
      ref.read(userProvider.notifier).state = user;

      // Save the token
      await _storageService.saveToken(user.token);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      _redirectToHome(user);
    } catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e is SocketException) {
        errorMessage = 'No internet connection. Please check your network and try again.';
        _showNoInternetDialog();
      } else if (e.toString().contains('User not found or wrong password')) {
        errorMessage = 'Invalid email or password. Please check your credentials and try again.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showNoInternetDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                Center(child: Image.asset('assets/images/HUST_icon.png')),
                Center(
                  child: Text(
                    'Welcome Back to AllHust',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                TextField(
                  controller: _emailController,
                  focusNode: emailFocusNode,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    prefixIcon: Icon(Icons.lock, color: theme.colorScheme.onPrimary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
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
                        color: theme.colorScheme.onPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onPrimary,
                    foregroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'SIGN IN',
                          style: TextStyle(fontSize: 18.0),
                        ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.signup);
                    },
                    child: Text(
                      'Create new account',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

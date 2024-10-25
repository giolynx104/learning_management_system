import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/routes/app_routes.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _obscureText = true;
  String _selectedRole = 'Student';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final signUpData = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'uuid': 11111, // For testing purposes, you might want to generate a random UUID
        'role': _selectedRole.toUpperCase(),
        'fullName': _fullNameController.text, // Add full name to sign up data
      };

      try {
        final result = await ref.read(signUpProvider(signUpData).future);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful!')),
        );
        // Navigate to the next screen or perform any other action
      } catch (e) {
        if (e.toString().contains('User already exists')) {
          _showUserExistsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up failed. Please try again.')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUserExistsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Already Exists'),
          content: const Text('An account with this email already exists. Would you like to sign in instead?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sign In'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.signin);
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
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text('Sign Up', style: TextStyle(color: theme.colorScheme.onPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.signin);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/images/HUST_icon.png'),
                Text(
                  'Welcome to AllHust',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _fullNameController,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                  decoration: InputDecoration(
                    labelText: 'Full Name (Optional)',
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    filled: true,
                    fillColor: theme.colorScheme.primary,
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    errorStyle: const TextStyle(color: Colors.yellow),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    filled: true,
                    fillColor: theme.colorScheme.primary,
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    errorStyle: const TextStyle(color: Colors.yellow),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    // Add email format validation if needed
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    filled: true,
                    fillColor: theme.colorScheme.primary,
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
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
                    errorStyle: const TextStyle(color: Colors.yellow),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    // Add password strength validation if needed
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  dropdownColor: theme.colorScheme.primary,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    filled: true,
                    fillColor: theme.colorScheme.primary,
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                    ),
                    errorStyle: const TextStyle(color: Colors.yellow),
                  ),
                  value: _selectedRole,
                  items: [
                    DropdownMenuItem(
                      value: 'Student',
                      child: Text('Student', style: TextStyle(color: theme.colorScheme.onPrimary)),
                    ),
                    DropdownMenuItem(
                      value: 'Lecturer',
                      child: Text('Lecturer', style: TextStyle(color: theme.colorScheme.onPrimary)),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onPrimary,
                    foregroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white,
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
                          'SIGN UP',
                          style: TextStyle(fontSize: 18.0),
                        ),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signin);
                  },
                  child: Text(
                    'Sign in with username/password',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
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

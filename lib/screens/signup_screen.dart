import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/routes/app_routes.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/components/auth_header.dart';
import 'package:learning_management_system/components/auth_text_field.dart';
import 'package:learning_management_system/widgets/custom_button.dart';
import 'package:learning_management_system/widgets/verification_dialog.dart';

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
      setState(() => _isLoading = true);

      try {
        // 1. Sign up the user
        final signUpData = {
          'email': _emailController.text,
          'password': _passwordController.text,
          'uuid': 11111,
          'role': _selectedRole.toUpperCase(),
        };

        final signUpResponse = await ref.read(signUpProvider(signUpData).future);
        
        if (!mounted) return;

        // 2. Show verification dialog with the code from signup response
        final verificationSuccess = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => VerificationDialog(
            email: _emailController.text,
            verificationCode: signUpResponse['verify_code'],
          ),
        );

        if (!mounted) return;

        if (verificationSuccess == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully!')),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.signin);
        }
      } catch (e) {
        if (!mounted) return;
        
        if (e.toString().contains('User already exists')) {
          _showUserExistsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showUserExistsDialog() {
    if (!mounted) return;
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
                Navigator.pushReplacementNamed(context, AppRoutes.signin);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AuthHeader(title: 'Welcome to AllHust'),
              _buildSignUpForm(),
              const SizedBox(height: 32.0),
              CustomButton(
                text: 'SIGN UP',
                onPressed: _handleSignUp,
                isLoading: _isLoading,
                backgroundColor: theme.colorScheme.onPrimary,
                textColor: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16.0),
              _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        AuthTextField(
          controller: _fullNameController,
          labelText: 'Full Name (Optional)',
        ),
        const SizedBox(height: 16.0),
        AuthTextField(
          controller: _emailController,
          labelText: 'Email',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            return null;
          },
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
        _buildRoleDropdown(),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    final theme = Theme.of(context);
    return DropdownButtonFormField<String>(
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
      items: ['Student', 'Lecturer'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: theme.colorScheme.onPrimary)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRole = newValue!;
        });
      },
      icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
      style: TextStyle(color: theme.colorScheme.onPrimary),
    );
  }

  Widget _buildSignInLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.signin);
      },
      child: Text(
        'Sign in with username/password',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
        ),
      ),
    );
  }
}

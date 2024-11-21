import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/components/auth_header.dart';
import 'package:learning_management_system/components/auth_text_field.dart';
import 'package:learning_management_system/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/signup_provider.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/utils/verification_helper.dart';

/// Screen for handling new user registration.
/// 
/// Provides a form for users to enter their:
/// - First and last name
/// - Email address
/// - Password
/// - Role (Student or Lecturer)
/// 
/// After successful registration, users need to verify their email
/// before they can sign in.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

/// The state class for [SignUpScreen].
/// 
/// Manages form validation, user input, and the registration process.
class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _obscureText = true;
  String _selectedRole = 'Student';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final signUpResponse = await ref.read(signUpProvider(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole.toUpperCase(),
      ).future);

      if (!mounted) return;

      if (signUpResponse['verify_code'] != null) {
        final verificationSuccess = await VerificationHelper.handleVerification(
          context: context,
          email: _emailController.text.trim(),
          verificationCode: signUpResponse['verify_code'],
        );

        if (!mounted) return;

        if (verificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please sign in.'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(Routes.signin);
        }
      } else {
        throw Exception('Verification code not received');
      }
    } catch (e) {
      if (!mounted) return;
      
      if (e.toString().contains('User already exists')) {
        _showUserExistsDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUserExistsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Exists'),
        content: const Text('An account with this email already exists. Would you like to sign in instead?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => context.pop(),
          ),
          TextButton(
            child: const Text('Sign In'),
            onPressed: () {
              context.pop();
              context.go(Routes.signin);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text('Sign Up',
            style: TextStyle(color: theme.colorScheme.onPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => context.go(Routes.signin),
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
          controller: _firstNameController,
          labelText: 'First Name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your first name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
        AuthTextField(
          controller: _lastNameController,
          labelText: 'Last Name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your last name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
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
          obscureText: _obscureText,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _togglePasswordVisibility,
          ),
          validator: _validatePassword,
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
          child:
              Text(value, style: TextStyle(color: theme.colorScheme.onPrimary)),
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
      onPressed: () => context.go(Routes.signin),
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

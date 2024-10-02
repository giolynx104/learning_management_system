import 'package:flutter/material.dart';
import 'package:learning_management_system/routes/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final FocusNode firstNameFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(firstNameFocusNode);
    });
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    super.dispose();
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
          child: Column(
            children: [
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
                focusNode: firstNameFocusNode,
                style: TextStyle(color: theme.colorScheme.onPrimary),
                decoration: InputDecoration(
                  labelText: 'First Name',
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
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                style: TextStyle(color: theme.colorScheme.onPrimary),
                decoration: InputDecoration(
                  labelText: 'Last Name',
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
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
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
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                obscureText: true,
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
                  suffixIcon: Icon(Icons.lock, color: theme.colorScheme.onPrimary),
                  errorStyle: const TextStyle(color: Colors.yellow),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
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
                value: 'Student',
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
                  // Handle role selection logic here
                },
                icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle sign up logic here
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimary,
                  foregroundColor: theme.colorScheme.primary,
                ),
                child: const Text(
                  'SIGN UP',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signin);
                },
                child: Text('Sign in with username/password',
                    style: TextStyle(color: theme.colorScheme.onPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

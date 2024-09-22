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
    return Scaffold(
      backgroundColor: Colors.red[900],
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              const Text(
                'Welcome to AllHust',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                focusNode: firstNameFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.red[900]!,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.red[900]!),
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.red[900]!,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.red[900]!),
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.red[900]!,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.red[900]!),
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.red[900]!,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.red[900]!),
                  ),
                  suffixIcon: const Icon(Icons.lock, color: Colors.white),
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
                dropdownColor: Colors.red[900]!,
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.red[900]!,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.red[900]!),
                  ),
                  errorStyle: const TextStyle(color: Colors.yellow),
                ),
                value: 'User',
                items: const [
                  DropdownMenuItem(
                    value: 'User',
                    child: Text('User', style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'Admin',
                    child: Text('Admin', style: TextStyle(color: Colors.white)),
                  ),
                ],
                onChanged: (String? newValue) {
                  // Handle role selection logic here
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle sign up logic here
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red[900]!,
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
                child: const Text('Sign in with username/password',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

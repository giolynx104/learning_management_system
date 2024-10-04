import 'package:flutter/material.dart';
import 'package:learning_management_system/routes/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final emailFocusNode = FocusNode();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(emailFocusNode);
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text('Sign In', style: TextStyle(color: theme.colorScheme.onPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.signup);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/images/HUST_icon.png'),
            Text(
              'Welcome Back to AllHust',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
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
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Handle sign in logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onPrimary,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text(
                'SIGN IN',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: theme.colorScheme.onPrimary,
                      title: Center(
                        child: Text(
                          'To retrieve a new password, please enter either your school-provided email address or your student ID (if you are a student).',
                          style: TextStyle(fontSize: 14.0, color: theme.colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      content: TextField(
                        style: TextStyle(color: theme.colorScheme.primary),
                        decoration: InputDecoration(
                          labelText: 'Enter your email',
                          labelStyle: TextStyle(color: theme.colorScheme.primary),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel',
                              style: TextStyle(color: theme.colorScheme.primary)),
                        ),
                        TextButton(
                          onPressed: () {
                            // Handle forgot password logic here
                          },
                          child: Text('Submit',
                              style: TextStyle(color: theme.colorScheme.primary)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Forgot Password?',
                  style: TextStyle(color: theme.colorScheme.onPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

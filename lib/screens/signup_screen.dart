import 'package:flutter/material.dart';
import 'package:learning_management_system/routes/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final FocusNode firstNameFocusNode = FocusNode();

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
      backgroundColor: Colors.red[900], // Changed to a deeper, richer red color
      appBar: AppBar(
        backgroundColor: Colors.red[900], // Changed to a deeper, richer red color
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Changed icon color to white
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.signin);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Welcome to AllHust',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Changed text color to white
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              focusNode: firstNameFocusNode,
              style: const TextStyle(color: Colors.white), // Changed text color to white
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: const TextStyle(color: Colors.white70), // Changed label color to white70
                filled: true, // Added filled property
                fillColor: Colors.red[900]!, // Changed fill color to red
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.red[900]!), // Changed border color to red
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              style: const TextStyle(color: Colors.white), // Changed text color to white
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: const TextStyle(color: Colors.white70), // Changed label color to white70
                filled: true, // Added filled property
                fillColor: Colors.red[900]!, // Changed fill color to red
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.red[900]!), // Changed border color to red
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              style: const TextStyle(color: Colors.white), // Changed text color to white
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white70), // Changed label color to white70
                filled: true, // Added filled property
                fillColor: Colors.red[900]!, // Changed fill color to red
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.red[900]!), // Changed border color to red
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white), // Changed text color to white
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white70), // Changed label color to white70
                filled: true, // Added filled property
                fillColor: Colors.red[900]!, // Changed fill color to red
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.red[900]!), // Changed border color to red
                ),
                suffixIcon: const Icon(Icons.lock, color: Colors.white), // Changed icon color to white
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: const TextStyle(color: Colors.white70), // Changed label color to white70
                filled: true, // Added filled property
                fillColor: Colors.red[900]!, // Changed fill color to red
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.red[900]!), // Changed border color to red
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'User',
                  child: Text('User', style: TextStyle(color: Colors.black)), // Changed text color to black
                ),
                DropdownMenuItem(
                  value: 'Admin',
                  child: Text('Admin', style: TextStyle(color: Colors.black)), // Changed text color to black
                ),
              ],
              onChanged: (String? newValue) {
                // Handle role selection logic here
              },
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Handle sign up logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Changed background color to white
                foregroundColor: Colors.red[900]!, // Changed text color to a deeper, richer red color
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
              child: const Text('Sign in with username/password', style: TextStyle(color: Colors.white)), // Changed text color to white
            ),
          ],
        ),
      ),
    );
  }
}

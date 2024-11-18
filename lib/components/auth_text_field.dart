import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: theme.colorScheme.onPrimary),
      decoration: InputDecoration(
        labelText: labelText,
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
        suffixIcon: suffixIcon,
        errorStyle: const TextStyle(color: Colors.yellow),
      ),
      validator: validator,
    );
  }
}

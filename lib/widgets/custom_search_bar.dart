import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              onSearch();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => onSearch(),
      ),
    );
  }
}

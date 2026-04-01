import 'package:flutter/material.dart';

class FoldersEmpty extends StatelessWidget {
  const FoldersEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'There are no folders yet',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
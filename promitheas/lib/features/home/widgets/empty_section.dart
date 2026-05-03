import 'package:flutter/material.dart';

class EmptySection extends StatelessWidget {
  const EmptySection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 190,
      child: Center(
        child: Text(
          'No products available',
          style: TextStyle(color: Color(0xFFC7C7CC)),
        ),
      ),
    );
  }
}

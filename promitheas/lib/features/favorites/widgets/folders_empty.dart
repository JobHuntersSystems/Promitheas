import 'package:flutter/material.dart';
/// Widget visual que representa el "Estado Vacío" de la cuadrícula de carpetas.
/// Se muestra cuando el usuario aún no ha creado ninguna carpeta de favoritos.
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
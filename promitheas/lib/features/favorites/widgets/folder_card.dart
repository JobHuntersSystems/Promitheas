import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:promitheas/core/theme/app_colors.dart';
import 'package:promitheas/features/favorites/models/favorite_folder.dart';

/// Tarjeta interactiva que representa una carpeta de favoritos.
/// Muestra el icono de la carpeta, su nombre y la cantidad de productos que contiene.
class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onLongPress,
    required this.color,
  });

  final FavoriteFolder folder;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // GestureDetector envuelve toda la tarjeta para capturar las interacciones del usuario
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN SUPERIOR: Iconos ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(Icons.folder_rounded, size: 26, color: color),
                  ),
                  const Spacer(),
                  // Botón de opciones (tres puntos)
                  // Se le añade su propio GestureDetector por si el usuario prefiere 
                  // tocar aquí en lugar de mantener pulsada toda la tarjeta.
                  GestureDetector(
                    onTap: onLongPress,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // --- SECCIÓN INFERIOR: Textos ---
              // Nombre de la carpeta
              Text(
                folder.folderName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${folder.productCount} products',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Esqueleto" animado (Skeleton Screen) que se muestra mientras los datos reales
/// de las carpetas se están descargando desde Supabase.
class FolderCardShimmer extends StatelessWidget {
  const FolderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              const Spacer(),
              Container(height: 10, color: AppColors.backgroundLight, width: double.infinity),
              const SizedBox(height: 4),
              Container(height: 8, color: AppColors.backgroundLight, width: 50),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Estado de "lista vacía" — distinto de [AppErrorWidget]: no hay nada que
/// reintentar, simplemente no hay resultados (filtro sin coincidencias,
/// catálogo vacío, etc.).
class EmptyStateWidget extends StatelessWidget {
  final String mensaje;
  final IconData icono;

  const EmptyStateWidget({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 48, color: AppColors.muted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(mensaje, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

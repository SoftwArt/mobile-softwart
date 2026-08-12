import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color? colorIcono;

  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icono, size: 18, color: colorIcono ?? AppColors.primary),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

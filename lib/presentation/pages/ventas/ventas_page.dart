import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/venta.dart';
import '../../providers/ventas_provider.dart';
import '../../widgets/filtro_menu_button.dart';
import '../../widgets/user_menu_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/pressable_scale.dart';
import '../../../core/navigation/app_page_route.dart';
import '../main_shell.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'venta_detalle_page.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final _searchController = TextEditingController();
  String _query = '';
  // null = todas | 'Pagada' | 'Pendiente'
  String? _filtroEstado;

  static const _opcionesFiltro = ['Pagada', 'Pendiente'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VentasProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Venta> _filtrar(List<Venta> todas) {
    return todas.where((v) {
      final matchQuery = _query.isEmpty ||
          (v.nombreCliente ?? '')
              .toLowerCase()
              .contains(_query.toLowerCase()) ||
          v.fecha.contains(_query) ||
          'venta #${v.idVenta}'.contains(_query.toLowerCase());
      bool matchEstado = true;
      if (_filtroEstado == 'Pagada') matchEstado = v.completado;
      if (_filtroEstado == 'Pendiente') matchEstado = !v.completado;
      return matchQuery && matchEstado;
    }).toList();
  }

  String _formatCOP(double v) {
    final s = v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '\$$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Ventas'),
        actions: const [UserMenuButton()],
      ),
      body: Consumer<VentasProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const ListSkeletonLoader();
          }
          if (provider.error != null) {
            return AppErrorWidget(
              mensaje: provider.error!,
              onRetry: () => provider.cargar(),
            );
          }

          final filtradas = _filtrar(provider.ventas);
          final totalFiltrado =
              filtradas.fold<double>(0, (sum, v) => sum + v.total);

          return RefreshIndicator(
            onRefresh: () => provider.cargar(),
            child: Column(
              children: [
                // Buscador + botón filtro
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por cliente, fecha o #...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      FiltroMenuButton(
                        opciones: _opcionesFiltro,
                        filtroActual: _filtroEstado,
                        onSelect: (v) => setState(() => _filtroEstado = v),
                      ),
                    ],
                  ),
                ),
                // Filtro activo badge
                if (_filtroEstado != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (_filtroEstado == 'Pagada'
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (_filtroEstado == 'Pagada'
                                      ? AppColors.success
                                      : AppColors.warning)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _filtroEstado!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _filtroEstado == 'Pagada'
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _filtroEstado = null),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: _filtroEstado == 'Pagada'
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Resumen
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtradas.length} venta${filtradas.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      if (filtradas.isNotEmpty)
                        Text(
                          'Total: ${_formatCOP(totalFiltrado)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: filtradas.isEmpty
                      ? const EmptyStateWidget(
                          mensaje: 'No hay ventas que coincidan',
                          icono: Icons.receipt_long_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          itemCount: filtradas.length,
                          itemBuilder: (context, index) {
                            final venta = filtradas[index];
                            final pagada = venta.completado;
                            return PressableScale(
                              onTap: () => Navigator.of(context).push(
                                AppPageRoute(
                                  builder: (_) =>
                                      VentaDetallePage(venta: venta),
                                ),
                              ),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    venta.nombreCliente ??
                                        'Venta #${venta.idVenta}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    formatFecha(venta.fecha),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatCOP(venta.total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: pagada
                                              ? AppColors.success
                                                  .withValues(alpha: 0.12)
                                              : AppColors.warning
                                                  .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          pagada ? 'Pagada' : 'Pendiente',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: pagada
                                                ? AppColors.success
                                                : AppColors.warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                                .animate(delay: (30 * index).ms)
                                .fadeIn(duration: 220.ms)
                                .slideY(
                                    begin: 0.08,
                                    duration: 220.ms,
                                    curve: Curves.easeOutCubic);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

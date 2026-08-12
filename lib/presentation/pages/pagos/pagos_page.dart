import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/pago.dart';
import '../../providers/pagos_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/pressable_scale.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../widgets/filtro_menu_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/user_menu_button.dart';
import 'pago_detalle_page.dart';
import '../main_shell.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PagosProvider>().cargar();
    });
  }

  List<Pago> _filtrar(List<Pago> pagos) {
    if (_busqueda.isEmpty) return pagos;
    final q = _busqueda.toLowerCase();
    return pagos.where((p) {
      return p.idVenta.toString().contains(q) ||
          (p.metodoPago?.toLowerCase().contains(q) ?? false) ||
          p.estadoPago.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Pagos'),
        actions: [
          Consumer<PagosProvider>(
            builder: (_, provider, __) => FiltroMenuButton(
              opciones: const ['Pendiente', 'Validado'],
              filtroActual: provider.filtroEstado,
              onSelect: provider.setFiltro,
            ),
          ),
          const UserMenuButton(),
        ],
      ),
      body: Consumer<PagosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const ListSkeletonLoader();
          if (provider.error != null) {
            return AppErrorWidget(
              mensaje: provider.error!,
              onRetry: provider.cargar,
            );
          }

          final pagos = _filtrar(provider.pagos);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por venta, método...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${pagos.length} pago(s)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: pagos.isEmpty
                    ? const EmptyStateWidget(
                        mensaje: 'No hay pagos que coincidan',
                        icono: Icons.payments_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: provider.cargar,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: pagos.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _PagoCard(pago: pagos[i], index: i),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PagoCard extends StatelessWidget {
  final Pago pago;
  final int index;
  const _PagoCard({required this.pago, required this.index});

  @override
  Widget build(BuildContext context) {
    final validado = pago.estadoPago.toLowerCase() == 'validado';
    return PressableScale(
      onTap: () => Navigator.push(
        context,
        AppPageRoute(builder: (_) => PagoDetallePage(pago: pago)),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: validado
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  validado ? Icons.check_circle_outline : Icons.schedule_rounded,
                  color: validado
                      ? AppColors.success
                      : AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Venta #${pago.idVenta}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pago.metodoPago ?? '—'}  ·  ${formatFecha(pago.fecha)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCOP(pago.monto),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: validado
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pago.estadoPago,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: validado
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (30 * index).ms)
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.08, duration: 220.ms, curve: Curves.easeOutCubic);
  }
}

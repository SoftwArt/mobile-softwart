import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cita.dart';
import '../../providers/citas_provider.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/user_menu_button.dart';
import '../../widgets/filtro_menu_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/pressable_scale.dart';
import '../../../core/navigation/app_page_route.dart';
import '../main_shell.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'cita_detalle_page.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _filtroEstado;

  static const _opcionesFiltro = [
    'Pendiente',
    'Confirmada',
    'Completada',
    'No Asistió',
    'Cancelada',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitasProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Cita> _filtrar(List<Cita> todas) {
    return todas.where((c) {
      final matchQuery = _query.isEmpty ||
          (c.nombreCliente ?? '')
              .toLowerCase()
              .contains(_query.toLowerCase()) ||
          c.fecha.contains(_query);
      final matchEstado = _filtroEstado == null ||
          c.estadoCita.toLowerCase() == _filtroEstado!.toLowerCase();
      return matchQuery && matchEstado;
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
        title: const Text('Citas'),
        actions: const [UserMenuButton()],
      ),
      body: Consumer<CitasProvider>(
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

          final filtradas = _filtrar(provider.citas);

          return RefreshIndicator(
            onRefresh: () => provider.cargar(),
            child: Column(
              children: [
                // Buscador + botón de filtro
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por cliente o fecha...',
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
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _filtroEstado!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _filtroEstado = null),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Contador
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  child: Row(
                    children: [
                      Text(
                        '${filtradas.length} cita${filtradas.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: filtradas.isEmpty
                      ? const EmptyStateWidget(
                          mensaje: 'No hay citas que coincidan',
                          icono: Icons.event_busy_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          itemCount: filtradas.length,
                          itemBuilder: (context, index) {
                            final cita = filtradas[index];
                            return _CitaTile(
                              cita: cita,
                              index: index,
                              onTap: () => Navigator.of(context).push(
                                AppPageRoute(
                                  builder: (_) => CitaDetallePage(cita: cita),
                                ),
                              ),
                            );
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

class _CitaTile extends StatelessWidget {
  final Cita cita;
  final int index;
  final VoidCallback onTap;

  const _CitaTile(
      {required this.cita, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          title: Text(
            cita.nombreCliente ?? 'Cliente sin nombre',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            '${formatFecha(cita.fecha)}  •  ${formatHora(cita.hora)}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: EstadoBadge(texto: cita.estadoCita),
        ),
      ),
    )
        .animate(delay: (30 * index).ms)
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.08, duration: 220.ms, curve: Curves.easeOutCubic);
  }
}

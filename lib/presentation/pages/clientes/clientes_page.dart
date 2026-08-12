import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/clientes_provider.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/user_menu_button.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/pressable_scale.dart';
import '../../../core/navigation/app_page_route.dart';
import 'cliente_detalle_page.dart';
import '../main_shell.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientesProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Clientes'),
        actions: const [UserMenuButton()],
      ),
      body: Consumer<ClientesProvider>(
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

          final todos = provider.clientes;
          final filtrados = _query.isEmpty
              ? todos
              : todos.where((c) {
                  final q = _query.toLowerCase();
                  return c.nombre.toLowerCase().contains(q) ||
                      c.correo.toLowerCase().contains(q) ||
                      (c.documento ?? '').toLowerCase().contains(q);
                }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.cargar(),
            child: Column(
              children: [
                // Buscador
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, correo o documento...',
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
                // Contador
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filtrados.length} cliente${filtrados.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: filtrados.isEmpty
                      ? const EmptyStateWidget(
                          mensaje: 'No hay resultados',
                          icono: Icons.people_outline,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {
                            final cliente = filtrados[index];
                            return PressableScale(
                              onTap: () => Navigator.of(context).push(
                                AppPageRoute(
                                  builder: (_) =>
                                      ClienteDetallePage(cliente: cliente),
                                ),
                              ),
                              child: Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.accent.withValues(alpha: 0.4),
                                  child: Text(
                                    cliente.nombre[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  cliente.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cliente.correo,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (cliente.documento != null)
                                      Text(
                                        '${cliente.tipoDocumento ?? 'Doc'}: ${cliente.documento}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                  ],
                                ),
                                isThreeLine: cliente.documento != null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cliente.activo
                                            ? AppColors.success
                                            : AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.muted,
                                    ),
                                  ],
                                ),
                              ),
                              ),
                            )
                                .animate(delay: (30 * index).ms)
                                .fadeIn(duration: 220.ms)
                                .slideY(begin: 0.08, duration: 220.ms, curve: Curves.easeOutCubic);
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

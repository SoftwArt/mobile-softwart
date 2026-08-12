import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Drawer(
      child: Column(
        children: [
          // Header con fondo teal oscuro
          Container(
            width: double.infinity,
            color: AppColors.sidebar,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.sidebarAccent,
                  child: Text(
                    (usuario?.nombre ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sidebar,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  usuario?.nombre ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  usuario?.correo ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Menú de navegación
          Expanded(
            child: Container(
              color: AppColors.sidebar,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    route: '/dashboard',
                  ),
                  const _DrawerItem(
                    icon: Icons.event_outlined,
                    label: 'Citas',
                    route: '/citas',
                  ),
                  const _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Pedidos',
                    route: '/pedidos',
                  ),
                  const _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Ventas',
                    route: '/ventas',
                  ),
                  const _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'Clientes',
                    route: '/clientes',
                  ),
                  const Spacer(),
                  Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.logoutRed,
                      size: 20,
                    ),
                    title: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: AppColors.logoutRed,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.sidebarAccent.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppColors.sidebarAccent
              : Colors.white.withValues(alpha: 0.75),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive
                ? AppColors.sidebarAccent
                : Colors.white.withValues(alpha: 0.85),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          Navigator.of(context).pop();
          if (!isActive) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cita.dart';
import '../../providers/citas_provider.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/estado_chip_selector.dart';

class CitaDetallePage extends StatefulWidget {
  final Cita cita;

  const CitaDetallePage({super.key, required this.cita});

  @override
  State<CitaDetallePage> createState() => _CitaDetallePageState();
}

class _CitaDetallePageState extends State<CitaDetallePage> {
  static const _estados = [
    (id: 1, nombre: 'Pendiente'),
    (id: 2, nombre: 'Completada'),
    (id: 3, nombre: 'No Asistió'),
    (id: 4, nombre: 'Cancelada'),
  ];

  int? _estadoSeleccionado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _estadoSeleccionado = widget.cita.idEstadoCita;
  }

  Future<void> _guardar() async {
    if (_estadoSeleccionado == null ||
        _estadoSeleccionado == widget.cita.idEstadoCita) return;

    setState(() => _guardando = true);
    final ok = await context
        .read<CitasProvider>()
        .cambiarEstado(widget.cita.idCita, _estadoSeleccionado!);
    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<CitasProvider>().error ?? 'Error al actualizar',
          ),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cita = widget.cita;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'Cliente',
                      valor: cita.nombreCliente ?? '—',
                    ),
                    _InfoRow(
                      label: 'Correo',
                      valor: cita.correoCliente ?? '—',
                    ),
                    _InfoRow(label: 'Fecha', valor: formatFecha(cita.fecha)),
                    _InfoRow(label: 'Hora', valor: formatHora(cita.hora)),
                    if (cita.observaciones != null &&
                        cita.observaciones!.isNotEmpty)
                      _InfoRow(
                        label: 'Observaciones',
                        valor: cita.observaciones!,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Estado: ',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        EstadoBadge(texto: cita.estadoCita),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cambiar estado',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 10),
            EstadoChipSelector(
              opciones: _estados,
              valorActual: _estadoSeleccionado,
              onChanged: (id) => setState(() => _estadoSeleccionado = id),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String valor;

  const _InfoRow({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

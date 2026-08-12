import '../../domain/entities/venta.dart';

class VentaModel extends Venta {
  const VentaModel({
    required super.idVenta,
    super.nombreCliente,
    required super.total,
    required super.estado,
    required super.completado,
    required super.numAbonos,
    required super.porcentajePrimerAbono,
    required super.fecha,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    // Backend retorna client como objeto anidado: { id_cliente, nombre, correo, ... }
    final clientMap = json['client'];
    final nombreCliente = clientMap is Map<String, dynamic>
        ? clientMap['nombre'] as String?
        : clientMap as String?;

    // total viene como string decimal desde PostgreSQL (ej: "150000.00")
    final totalRaw = json['total'];
    final total = totalRaw is num
        ? totalRaw.toDouble()
        : double.tryParse(totalRaw?.toString() ?? '0') ?? 0.0;

    return VentaModel(
      idVenta: json['id_venta'] as int,
      nombreCliente: nombreCliente,
      total: total,
      estado: json['estado'] as bool? ?? false,
      completado: json['completado'] as bool? ?? false,
      numAbonos: json['num_abonos'] as int? ?? 2,
      porcentajePrimerAbono: json['porcentaje_primer_abono'] as int? ?? 70,
      fecha: json['fecha'] as String? ?? '',
    );
  }
}

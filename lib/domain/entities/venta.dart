class Venta {
  final int idVenta;
  final String? nombreCliente;
  final double total;
  final bool estado; // true = activo / no anulado
  final bool completado; // true = pagos completos
  final int numAbonos;
  final int porcentajePrimerAbono;
  final String fecha;

  const Venta({
    required this.idVenta,
    this.nombreCliente,
    required this.total,
    required this.estado,
    required this.completado,
    required this.numAbonos,
    required this.porcentajePrimerAbono,
    required this.fecha,
  });
}

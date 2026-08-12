import '../../core/errors/exceptions.dart';
import '../../domain/entities/venta.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/ventas_datasource.dart';

class VentasRepositoryImpl implements VentasRepository {
  final VentasDatasource _datasource;
  final AuthLocalDataSource _localDataSource;

  VentasRepositoryImpl(
    this._datasource,
    [AuthLocalDataSource? localDataSource]
  ) : _localDataSource = localDataSource ?? AuthLocalDataSource();

  Future<String> _getToken() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw const UnauthorizedException('Sin sesión activa');
    return token;
  }

  @override
  Future<List<Venta>> getVentas() async {
    return _datasource.getVentas(await _getToken());
  }

  @override
  Future<Map<String, dynamic>> getEstadoPagos(int idVenta) async {
    return _datasource.getEstadoPagos(
      token: await _getToken(),
      idVenta: idVenta,
    );
  }
}

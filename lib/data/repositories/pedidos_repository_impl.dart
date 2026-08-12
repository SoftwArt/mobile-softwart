import '../../core/errors/exceptions.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/estado_servicio.dart';
import '../../domain/repositories/pedidos_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/pedidos_datasource.dart';

class PedidosRepositoryImpl implements PedidosRepository {
  final PedidosDatasource _datasource;
  final AuthLocalDataSource _localDataSource;

  PedidosRepositoryImpl(
    this._datasource,
    [AuthLocalDataSource? localDataSource]
  ) : _localDataSource = localDataSource ?? AuthLocalDataSource();

  Future<String> _getToken() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw const UnauthorizedException('Sin sesión activa');
    return token;
  }

  @override
  Future<List<Pedido>> getPedidos() async {
    return _datasource.getPedidos(await _getToken());
  }

  @override
  Future<List<EstadoServicio>> getEstadosServicio() async {
    return _datasource.getEstadosServicio(await _getToken());
  }

  @override
  Future<void> cambiarEstado({
    required int idDetalle,
    required int idEstado,
  }) async {
    await _datasource.cambiarEstado(
      token: await _getToken(),
      idDetalle: idDetalle,
      idEstado: idEstado,
    );
  }
}

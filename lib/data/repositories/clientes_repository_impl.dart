import '../../core/errors/exceptions.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/clientes_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/clientes_datasource.dart';

class ClientesRepositoryImpl implements ClientesRepository {
  final ClientesDatasource _datasource;
  final AuthLocalDataSource _localDataSource;

  ClientesRepositoryImpl(
    this._datasource,
    [AuthLocalDataSource? localDataSource]
  ) : _localDataSource = localDataSource ?? AuthLocalDataSource();

  Future<String> _getToken() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw const UnauthorizedException('Sin sesión activa');
    return token;
  }

  @override
  Future<List<Cliente>> getClientes() async {
    return _datasource.getClientes(await _getToken());
  }
}

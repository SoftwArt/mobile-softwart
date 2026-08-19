import '../../core/errors/exceptions.dart';
import '../../domain/entities/cita.dart';
import '../../domain/repositories/citas_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/citas_datasource.dart';

class CitasRepositoryImpl implements CitasRepository {
  final CitasDatasource _datasource;
  final AuthLocalDataSource _localDataSource;

  CitasRepositoryImpl(this._datasource, [AuthLocalDataSource? localDataSource])
      : _localDataSource = localDataSource ?? AuthLocalDataSource();

  Future<String> _getToken() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw const UnauthorizedException('Sin sesión activa');
    return token;
  }

  @override
  Future<List<Cita>> getCitas() async {
    return _datasource.getCitas(await _getToken());
  }

  @override
  Future<void> cambiarEstado({
    required int idCita,
    required int idEstado,
  }) async {
    await _datasource.cambiarEstado(
      token: await _getToken(),
      idCita: idCita,
      idEstado: idEstado,
    );
  }
}

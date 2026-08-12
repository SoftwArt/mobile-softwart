import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/auth_local_datasource.dart';

// Implementación concreta del repositorio de auth
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    AuthDatasource? datasource,
    AuthLocalDataSource? localDataSource,
  })  : _datasource = datasource ?? AuthDatasource(),
        _localDataSource = localDataSource ?? AuthLocalDataSource();

  @override
  Future<({Usuario usuario, String token})> login({
    required String correo,
    required String clave,
  }) async {
    final result = await _datasource.login(correo: correo, clave: clave);
    await _localDataSource.saveToken(result.token);
    return (usuario: result.usuario, token: result.token);
  }

  @override
  Future<void> logout() async {
    await _localDataSource.deleteToken();
  }
}

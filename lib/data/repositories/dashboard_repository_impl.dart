import '../../core/errors/exceptions.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/dashboard_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDatasource _datasource;
  final AuthLocalDataSource _localDataSource;

  DashboardRepositoryImpl(
    this._datasource,
    [AuthLocalDataSource? localDataSource]
  ) : _localDataSource = localDataSource ?? AuthLocalDataSource();

  @override
  Future<DashboardStats> getStats() async {
    final token = await _localDataSource.getToken();
    if (token == null) throw const UnauthorizedException('Sin sesión activa');
    return _datasource.getStats(token);
  }
}

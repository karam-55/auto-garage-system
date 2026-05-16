import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/cache_datasource.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/backend_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(BackendConstants.backendUrl);
});

final cacheDataSourceProvider = FutureProvider<CacheDataSource>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return CacheDataSource(prefs);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dioClient);
});

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final cacheDataSource = await ref.watch(cacheDataSourceProvider.future);
  return AuthRepositoryImpl(remoteDataSource, cacheDataSource);
});

final loginUseCaseProvider = FutureProvider<LoginUseCase>((ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return LoginUseCase(repository);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState.initial());

  Future<void> login(String username, String password) async {
    state = AuthState.loading();
    
    try {
      final useCase = await _ref.read(loginUseCaseProvider.future);
      final user = await useCase(username, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    
    try {
      final repository = await _ref.read(authRepositoryProvider.future);
      await repository.logout();
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    state = AuthState.loading();
    
    try {
      final repository = await _ref.read(authRepositoryProvider.future);
      final user = await repository.getLoggedInUser();
      
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.initial();
    }
  }
}

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  factory AuthState.initial() => AuthState();
  factory AuthState.loading() => AuthState(isLoading: true);
  factory AuthState.authenticated(User user) => AuthState(user: user);
  factory AuthState.error(String error) => AuthState(error: error);

  bool get isAuthenticated => user != null;
}

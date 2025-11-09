import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/api_exceptions.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.initial() {
    return AuthState();
  }

  factory AuthState.loading() {
    return AuthState(isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(user: user, isAuthenticated: true, isLoading: false);
  }

  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState.initial()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    state = AuthState.loading();

    try {
      final hasSession = await _authService.checkAndRefreshToken();

      if (hasSession) {
        final user = await _authService.getCurrentUser();
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = AuthState.loading();

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      state = AuthState.authenticated(authResponse.user);
      return true;
    } on ValidationException catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
      return false;
    } on UnauthorizedException {
      state = AuthState.unauthenticated(
        errorMessage: 'Credenciales incorrectas',
      );
      return false;
    } on NetworkException {
      state = AuthState.unauthenticated(
        errorMessage: 'No hay conexión a internet',
      );
      return false;
    } catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    state = AuthState.loading();

    try {
      final authResponse = await _authService.signup(
        email: email,
        password: password,
        name: name,
      );

      state = AuthState.authenticated(authResponse.user);
      return true;
    } on ValidationException catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
      return false;
    } on ConflictException {
      state = AuthState.unauthenticated(
        errorMessage: 'Este correo ya está registrado',
      );
      return false;
    } on NetworkException {
      state = AuthState.unauthenticated(
        errorMessage: 'No hay conexión a internet',
      );
      return false;
    } catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

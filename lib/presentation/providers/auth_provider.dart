import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth State Provider - Firebase authentication durumunu dinler
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Is Signed In Provider
final isSignedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// User Display Name Provider
final userDisplayNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName ?? 'Kullanıcı';
});

/// User Email Provider
final userEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email;
});

/// User Photo URL Provider
final userPhotoURLProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.photoURL;
});

/// Auth Controller - Authentication işlemlerini yönetir
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AsyncValue.data(null));

  /// Google ile giriş yap
  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.signInWithGoogle();
      state = const AsyncValue.data(null);
      return result != null;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Email ile giriş yap
  Future<bool> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.signInWithEmail(email, password);
      state = const AsyncValue.data(null);
      return result != null;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Email ile kayıt ol
  Future<bool> registerWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.registerWithEmail(email, password);
      state = const AsyncValue.data(null);
      return result != null;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Şifre sıfırlama emaili gönder
  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

/// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/domain/entities/user_entity.dart';
import 'package:taskmanager/domain/usecases/auth_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});
}

class AuthCubit extends Cubit<AuthState> {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.signInWithGoogleUseCase,
    required this.signUpWithEmailUseCase,
    required this.loginWithEmailUseCase,
    required this.logoutUseCase,
  }) : super(AuthState());

  /// Save user ID in SharedPreferences
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  /// Get saved user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Clear saved user ID
  Future<void> _clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<void> signInWithGoogle() async {
    emit(AuthState(isLoading: true));
    try {
      final user = await signInWithGoogleUseCase();
      if (user != null) {
        await _saveUserId(user.uid); // Save user ID
      }
      emit(AuthState(user: user));
    } catch (e) {
      emit(AuthState(error: e.toString()));
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    emit(AuthState(isLoading: true));
    try {
      final user = await signUpWithEmailUseCase(email, password);
      if (user != null) {
        await _saveUserId(user.uid); // Save user ID
      }
      emit(AuthState(user: user));
    } catch (e) {
      emit(AuthState(error: e.toString()));
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthState(isLoading: true));
    try {
      final user = await loginWithEmailUseCase(email, password);
      if (user != null) {
        await _saveUserId(user.uid); // Save user ID
      }
      emit(AuthState(user: user));
    } catch (e) {
      emit(AuthState(error: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthState(isLoading: true));
    await logoutUseCase();
    await _clearUserId(); // Remove user ID on logout
    emit(AuthState(user: null));
  }
}

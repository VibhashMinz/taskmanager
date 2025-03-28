import 'package:taskmanager/domain/entities/user_entity.dart';
import 'package:taskmanager/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity?> call() async {
    return await repository.signInWithGoogle();
  }
}

class SignUpWithEmailUseCase {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) async {
    return await repository.signUpWithEmail(email, password);
  }
}

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) async {
    return await repository.loginWithEmail(email, password);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call(String email) async {
    return await repository.forgotPassword(email);
  }
}

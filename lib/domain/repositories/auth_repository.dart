import 'package:taskmanager/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signUpWithEmail(String email, String password);
  Future<UserEntity?> loginWithEmail(String email, String password);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<UserEntity?> getCurrentUser();
}

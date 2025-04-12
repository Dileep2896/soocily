/* 
  Auth Repository - Outlines the possible authentication operations.
*/

import 'package:soocily/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password);

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword(
      String name, String email, String password);

  // Sign out
  Future<void> signOut();

  // Check if user is authenticated
  Future<AppUser?> getCurrentUser();
}

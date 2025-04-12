import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/auth/domain/entities/app_user.dart';
import 'package:soocily/features/auth/domain/repos/auth_repo.dart';
import 'package:soocily/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // check if user is authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  // get current user
  AppUser? get currentUser => _currentUser;

  // login with email and password
  void login(String email, String password) async {
    emit(AuthLoading());
    try {
      final AppUser? user =
          await authRepo.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // sign up with email and password
  void signUp(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final AppUser? user =
          await authRepo.signUpWithEmailAndPassword(name, email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // sign out
  void signOut() async {
    emit(AuthLoading());
    try {
      await authRepo.signOut();
      _currentUser = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

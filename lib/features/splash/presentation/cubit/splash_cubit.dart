import 'package:chat_app/features/auth/data/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashAuthenticated extends SplashState {}

class SplashUnauthenticated extends SplashState {}

class SplashError extends SplashState {
  final String message;
  SplashError(this.message);
}

class SplashCubit extends Cubit<SplashState> {
  final AuthRepo authRepo;

  SplashCubit({required this.authRepo}) : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    emit(SplashLoading());

    try {
      // Add a slight delay to ensure services are initialized
      await Future.delayed(const Duration(milliseconds: 1500));

      final currentUser = authRepo.currentUser;

      if (currentUser != null) {
        emit(SplashAuthenticated());
      } else {
        emit(SplashUnauthenticated());
      }
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}

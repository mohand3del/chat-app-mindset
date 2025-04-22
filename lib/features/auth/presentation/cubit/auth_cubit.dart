import 'dart:developer';
import 'package:chat_app/features/auth/data/auth_repository.dart';
import 'package:chat_app/features/auth/data/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';



class AuthCubit extends Cubit<AuthState> {
  final AuthRepo repo;

  AuthCubit(this.repo) : super(AuthInitial());

  void signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      await repo.signUp(email, password);
      emit(AuthSuccess(
        UserModel(
          id: repo.currentUser!.id,
          email: repo.currentUser!.email ?? email,
          lastSeen: DateTime.now(),
          avatarUrl: repo.currentUser!.userMetadata!['avatar_url'] ?? '',
        fullName:repo.currentUser!.userMetadata!['full_name'] ?? '',
        createdAt: DateTime.now(),
        
        ),
        
      ));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await repo.signIn(email, password);
      emit(AuthSuccess(
          UserModel(
          id: repo.currentUser!.id,
          email: repo.currentUser!.email ?? email,
          lastSeen: DateTime.now(),
          avatarUrl: repo.currentUser!.userMetadata!['avatar_url'] ?? '',
          fullName: repo.currentUser!.userMetadata!['full_name'] ?? '',
          createdAt: DateTime.now(),
        ),
      ));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void signOut() async {
    await repo.signOut();
    emit(AuthLoggedOut());
  }

  void checkSession() {
    if (repo.currentUser != null) {
      emit(AuthSuccess(
          UserModel(
          id: repo.currentUser!.id,
          email: repo.currentUser!.email ?? "" ,
          lastSeen: DateTime.now(),
          avatarUrl: repo.currentUser!.userMetadata!['avatar_url'] ?? '',
          fullName: repo.currentUser!.userMetadata!['full_name'] ?? '',
          createdAt: DateTime.now(),
        ),
      ));
    } else {
      emit(AuthLoggedOut());
    }
  }
}

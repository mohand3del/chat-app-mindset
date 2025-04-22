import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/auth/data/user_model.dart';
import 'package:chat_app/features/users/data/users_repository.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final _usersRepository = UsersRepository();
  StreamSubscription? _usersSubscription;

  UsersCubit() : super(UsersInitial());

  Future<void> loadUsers(String currentUserId) async {
    emit(UsersLoading());
    try {
      // Initial load
      final users = await _usersRepository.getUsers(currentUserId);
      emit(UsersLoaded(users));

      // Set up real-time subscription
      _usersSubscription?.cancel();
      _usersSubscription =
          _usersRepository.getUsersStream(currentUserId).listen((users) {
        emit(UsersLoaded(users));
      });
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> updateUserStatus(String userId) async {
    try {
      await _usersRepository.updateLastSeen(userId);
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}

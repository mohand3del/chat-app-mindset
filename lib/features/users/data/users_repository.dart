import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/core/constants/supabase_config.dart';
import 'package:chat_app/features/auth/data/user_model.dart';

class UsersRepository {
  final _supabase = Supabase.instance.client;

  Future<List<UserModel>> getUsers(String currentUserId) async {
    final response = await _supabase
        .from(SupabaseConfig.usersTable)
        .select()
        .neq('id', currentUserId)
        .order('last_seen', ascending: false);

    return response.map<UserModel>((user) => UserModel.fromJson(user)).toList();
  }

  Stream<List<UserModel>> getUsersStream(String currentUserId) {
    return _supabase
        .from(SupabaseConfig.usersTable)
        .stream(primaryKey: ['id'])
        .neq('id', currentUserId)
        .order('last_seen', ascending: false)
        .map((data) =>
            data.map<UserModel>((user) => UserModel.fromJson(user)).toList());
  }

  Future<void> updateLastSeen(String userId) async {
    await _supabase.from(SupabaseConfig.usersTable).update(
        {'last_seen': DateTime.now().toIso8601String()}).eq('id', userId);
  }
}

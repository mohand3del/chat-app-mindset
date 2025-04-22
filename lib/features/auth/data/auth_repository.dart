import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/core/constants/supabase_config.dart';
import 'package:chat_app/features/auth/data/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthRepo {
  final _client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}

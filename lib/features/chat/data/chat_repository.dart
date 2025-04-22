import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_app/core/constants/supabase_config.dart';
import 'package:chat_app/features/chat/data/chat_message_model.dart';
import 'package:path/path.dart' as path;

class ChatRepository {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<List<ChatMessageModel>> getChatMessages(
      String currentUserId, String otherUserId) async {
    final response = await _supabase
        .from(SupabaseConfig.chatsTable)
        .select()
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .or('sender_id.eq.$otherUserId,receiver_id.eq.$otherUserId')
        .order('created_at');

    final messages =
        response.map((msg) => ChatMessageModel.fromJson(msg)).toList();

    // Filter messages between these two users only
    return messages.where((msg) {
      return (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
          (msg.senderId == otherUserId && msg.receiverId == currentUserId);
    }).toList();
  }

  Stream<List<ChatMessageModel>> getChatMessagesStream(
      String currentUserId, String otherUserId) {
    return _supabase
        .from(SupabaseConfig.chatsTable)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((events) {
          return events
              .map((event) => ChatMessageModel.fromJson(event))
              .where((msg) {
            return (msg.senderId == currentUserId &&
                    msg.receiverId == otherUserId) ||
                (msg.senderId == otherUserId &&
                    msg.receiverId == currentUserId);
          }).toList();
        });
  }

  Future<ChatMessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    File? imageFile,
  }) async {
    String? imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      try {
        final fileExtension = path.extension(imageFile.path);
        final fileName = '${const Uuid().v4()}$fileExtension';

        await _supabase.storage.from('chat_images').upload(fileName, imageFile);

        imageUrl = _supabase.storage.from('chat_images').getPublicUrl(fileName);
      } catch (e) {
        // Handle image upload error
      }
    }

    final messageData = {
      'id': const Uuid().v4(),
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
      'image_url': imageUrl,
    };

    await _supabase.from(SupabaseConfig.chatsTable).insert(messageData);

    return ChatMessageModel.fromJson(messageData);
  }

  Future<void> markMessagesAsRead(
      String currentUserId, String otherUserId) async {
    await _supabase
        .from(SupabaseConfig.chatsTable)
        .update({'is_read': true})
        .eq('sender_id', otherUserId)
        .eq('receiver_id', currentUserId)
        .eq('is_read', false);
  }

  Future<void> startTyping(String userId, String receiverId) async {
    final payload = {
      'user_id': userId,
      'receiver_id': receiverId,
      'is_typing': true,
    };

    await _supabase.channel(SupabaseConfig.typingChannel).sendBroadcastMessage(
          event: 'typing',
          payload: payload,
        );
  }

  Future<void> stopTyping(String userId, String receiverId) async {
    final payload = {
      'user_id': userId,
      'receiver_id': receiverId,
      'is_typing': false,
    };

    await _supabase.channel(SupabaseConfig.typingChannel).sendBroadcastMessage(
          event: 'typing',
          payload: payload,
        );
  }
}

class SupabaseConfig {
  static const String chatsTable = 'chats';
  static const String typingChannel = 'typing_channel';
}

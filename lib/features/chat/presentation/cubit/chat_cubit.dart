import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat/data/chat_repository.dart';
import 'package:chat_app/features/chat/data/chat_message_model.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final _chatRepository = ChatRepository();
  StreamSubscription? _messagesSubscription;
  
  ChatCubit() : super(ChatInitial());
  
  Future<void> loadMessages(String currentUserId, String otherUserId) async {
    emit(ChatLoading());
    try {
      // Initial load
      final messages = await _chatRepository.getChatMessages(currentUserId, otherUserId);
      emit(ChatLoaded(messages));
      
      // Mark received messages as read
      await _chatRepository.markMessagesAsRead(currentUserId, otherUserId);
      
      // Set up real-time subscription
      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.getChatMessagesStream(currentUserId, otherUserId).listen((messages) {
        emit(ChatLoaded(messages));
        
        // Mark received messages as read when they come in
        _chatRepository.markMessagesAsRead(currentUserId, otherUserId);
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
  
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    if (state is ChatLoaded) {
      try {
        await _chatRepository.sendMessage(
          senderId: senderId,
          receiverId: receiverId,
          message: message,
        );
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }
  
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
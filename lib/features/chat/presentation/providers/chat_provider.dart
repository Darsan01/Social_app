import 'package:flutter/material.dart';
import '../../data/chat_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/di/service_locator.dart';

class ChatProvider with ChangeNotifier {
  final _chatRepository = ChatRepository();
  final _authProvider = getIt<AuthProvider>();
  
  Map<String, int> unreadCounts = {};
  bool isLoading = false;

  Future<void> sendMessage(String receiverId, String message) async {
    isLoading = true;
    notifyListeners();
    
    try {
      await _chatRepository.sendMessage(
        _authProvider.currentUser!.uid,
        receiverId,
        message,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateUnreadCount(String chatId, int count) {
    unreadCounts[chatId] = count;
    notifyListeners();
  }

  Future<void> markAsRead(String chatId) async {
    unreadCounts[chatId] = 0;
    notifyListeners();
  }
}

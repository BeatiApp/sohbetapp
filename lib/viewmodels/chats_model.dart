import 'package:get_it/get_it.dart';
import 'package:sohbetapp/core/services/chat_service.dart';
import 'package:sohbetapp/models/conversation.dart';
import 'base_model.dart';

class ChatsModel extends BaseModel {
  final ChatService _db = GetIt.instance<ChatService>();

  Stream<List<Conversation>> conversations(String userId) {
    return _db.getConversations(userId);
  }

  Stream<List<Conversation>> getConversationQuery(
    String userId,
    String query,
  ) {
    return _db.getConversationsQuery(userId, query);
  }

  Stream<List<Conversation>> getArchivedConversations(String userId) {
    return _db.getArchivedConversations(userId);
  }
}

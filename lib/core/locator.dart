import 'package:get_it/get_it.dart';
import 'package:sohbetapp/core/services/news_service.dart';
import 'package:sohbetapp/core/services/messaging_service.dart';
import 'package:sohbetapp/core/services/services.dart';
import 'package:sohbetapp/core/services/storage_service.dart';
import 'package:sohbetapp/core/services/story_service.dart';
import 'package:sohbetapp/viewmodels/chats_model.dart';
import 'package:sohbetapp/viewmodels/contacts_model.dart';
import 'package:sohbetapp/viewmodels/conversation_model.dart';
import 'package:sohbetapp/viewmodels/main_model.dart';
import 'package:sohbetapp/core/services/chat_service.dart';
import 'package:sohbetapp/core/services/auth_service.dart';
import 'package:sohbetapp/core/services/navigator_service.dart';
import 'package:sohbetapp/core/services/profileService.dart';

GetIt getIt = GetIt.instance;

setupLocators() {
  getIt.registerLazySingleton(() => MessagingService());
  getIt.registerLazySingleton(() => NavigatorService());
  getIt.registerLazySingleton(() => ChatService());
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => NewsService());
  getIt.registerLazySingleton(() => ProfileService());
  getIt.registerLazySingleton(() => ChatSettings());
  getIt.registerLazySingleton(() => StoryService());

  getIt.registerFactory(() => MainModel());
  getIt.registerFactory(() => ChatsModel());
  getIt.registerFactory(() => ContactsModel());
  getIt.registerFactory(() => ConversationModel());
  getIt.registerFactory(() => StorageService());
}

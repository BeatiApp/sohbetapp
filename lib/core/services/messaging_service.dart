import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/core/services/chat_service.dart';
import 'package:sohbetapp/core/services/navigator_service.dart';
import 'package:sohbetapp/screens/chats/conversation_page.dart';
import 'package:http/http.dart' as http;
import 'package:sohbetapp/utilities/apis.dart';

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final NavigatorService navigatorService = getIt<NavigatorService>();
  final ChatService chatService = getIt<ChatService>();
  MessagingService() {
    _firebaseMessaging.getToken().then((value) => print(value));
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: notificationClicked,
      onResume: notificationClicked,
    );
  }

  Future notificationClicked(Map<String, dynamic> message) async {
    var data = message['data'];
    var conv =
        chatService.getConverstation(data['conversationId'], data['senderId']);

    await navigatorService.navigateTo(ConversationPage(
      conversation: conv,
      userId: data['receiverId'],
    ));
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  Future<String> getUserToken() {
    return _firebaseMessaging.getToken();
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage(
      String messageBody, String messageTitle, String token) async {
    await _firebaseMessaging.requestNotificationPermissions();

    await http
        .post(
      'https://fcm.googleapis.com//v1/projects/sohbetapp-1339e/messages:send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$fcmToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': messageBody ?? "Yeni Bir Mesaj Aldınız",
            'title': messageTitle ?? "Mesaj Başlığı",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    )
        .catchError((onError) {
      print(onError);
    });

    print(jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': messageBody ?? "Yeni Bir Mesaj Aldınız",
          'title': messageTitle ?? "Mesaj Başlığı",
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to': token,
      },
    ));

    Map<String, dynamic> map;

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        map = message;
        print(message);
      },
    );

    return map;
  }
}

import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohbetapp/utilities/sensitive_constants.dart';

class ChatSettings {
  Future<String> getChatImage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String chatImage = preferences.getString("chat_image");
    return chatImage;
  }

  Future<bool> getSohbetSystemInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("showSohbetSystem");
  }

  putChatImage(String imageFile) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("chat_image", imageFile);
  }

  Future<Map<String, double>> getStorageData() async {
    double audioDirSize = _dirStatSync(storagePath + "/Audios") ?? 0.0;
    double imagesDirSize = _dirStatSync(storagePath + "/Images") ?? 0.0;
    double otherDirSize = _dirStatSync(storagePath + "/Files") ?? 0.0;
    double videoDirSize = _dirStatSync(storagePath + "/Videos") ?? 0.0;
    double locationDirSize = _dirStatSync(storagePath + "/Locations") ?? 0.0;

    Map<String, double> mapData = {
      "Ses Dosyaları": audioDirSize,
      "Resimler": imagesDirSize,
      "Videolar": videoDirSize,
      "Konum Dosyaları": locationDirSize,
      "Diğer Dosyalar": otherDirSize
    };

    return mapData;
  }

  double _dirStatSync(String dirPath) {
    int totalSize = 0;
    var dir = Directory(dirPath);
    try {
      if (dir.existsSync()) {
        dir
            .listSync(recursive: true, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }

    return totalSize.toDouble();
  }
}

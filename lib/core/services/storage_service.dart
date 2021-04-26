import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:path/path.dart' as path;
import 'package:sohbetapp/utilities/sensitive_constants.dart';
import 'package:sohbetapp/viewmodels/base_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class StorageService extends BaseModel {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool busyFileUploadSystem = false;
  String fileName;
  double fileProgress;
  Future<Map<String, dynamic>> uploadMedia(File file) async {
    busyFileUploadSystem = true;
    if (!Directory(storagePath + "/Audios").existsSync()) {
      Directory(storagePath + "/Audios").createSync();
    }

    if (!Directory(storagePath + "/Images").existsSync()) {
      Directory(storagePath + "/Images").createSync();
    }

    if (!Directory(storagePath + "/Locations").existsSync()) {
      Directory(storagePath + "/Locations").createSync();
    }

    if (!Directory(storagePath + "/Files").existsSync()) {
      Directory(storagePath + "/Files").createSync();
    }
    fileName = path.basename(file.path);
    String extension = path.extension(file.path).replaceAll(".", "");
    var uploadTask = _firebaseStorage
        .ref()
        .child(
            "$extension/SOHBET-MEDIA-${firebaseAuth.currentUser.uid}-${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}")
        .putFile(file);

    uploadTask.events.listen((event) {
      fileProgress = event.snapshot.bytesTransferred.toDouble();
    });

    var storageRef = await uploadTask.onComplete;

    String url = await storageRef.ref.getDownloadURL();
    busyFileUploadSystem = false;
    fileName = null;

    return {
      "url": url,
      "fileName": path.basename(file.path),
      "fileSize": file.lengthSync().toString()
    };
  }

  Future<List<String>> uploadDiaryMedia(List<File> fileList) async {
    busyFileUploadSystem = true;

    List<String> urlList = [];
    if (!Directory(storagePath + "/Diaries").existsSync()) {
      Directory(storagePath + "/Diaries").createSync();
    }
    fileList.forEach((file) async {
      fileName = path.basename(file.path);
      String extension = path.extension(file.path).replaceAll(".", "");
      var uploadTask = _firebaseStorage
          .ref()
          .child(
              "$extension/SOHBET-MEDIA-${firebaseAuth.currentUser.uid}-${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}")
          .putFile(file);

      uploadTask.events.listen((event) {
        fileProgress = event.snapshot.bytesTransferred.toDouble();
      });

      var storageRef = await uploadTask.onComplete;

      storageRef.ref.getDownloadURL().then((value) {
        print(value);
        urlList.add(value);
        print(urlList.length);

        notifyListeners();
      });
    });

    return urlList;
  }

  Future<Map<String, dynamic>> uploadVideo(File file) async {
    busyFileUploadSystem = true;
    fileName = path.basename(file.path);
    if (!Directory(storagePath + "/Videos").existsSync()) {
      Directory(storagePath + "/Videos").createSync();
    }
    if (!Directory(storagePath + "/Video-Thumbnails").existsSync()) {
      Directory(storagePath + "/Video-Thumbnails").createSync();
    }

    var thumbnail = await VideoThumbnail.thumbnailData(
        video: file.path, imageFormat: ImageFormat.PNG);
    File newThumbnail = await File(storagePath +
            "/Video-Thumbnails/" +
            "SOHBET-VIDEO-THUMBNAIL-${path.basename(file.path).replaceAll(path.extension(file.path), '')}.png")
        .writeAsBytes(thumbnail);

    String extension = path.extension(file.path).replaceAll(".", "");
    var uploadTask = _firebaseStorage
        .ref()
        .child(
            "$extension/SOHBET-MEDIA-${firebaseAuth.currentUser.uid}-${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}")
        .putFile(file);

    uploadTask.events.listen((event) {
      fileProgress = event.snapshot.bytesTransferred.toDouble();
    });

    var storageRef = await uploadTask.onComplete;

    var uploadTaskThumb = _firebaseStorage
        .ref()
        .child(
            "$extension/SOHBET-MEDIA-${firebaseAuth.currentUser.uid}-${DateTime.now().millisecondsSinceEpoch}.${newThumbnail.path.split('.').last}")
        .putFile(newThumbnail);

    uploadTaskThumb.events.listen((event) {});

    var storageRefThumb = await uploadTaskThumb.onComplete;
    busyFileUploadSystem = false;
    fileName = null;
    String url = await storageRef.ref.getDownloadURL();
    String thumbURL = await storageRefThumb.ref.getDownloadURL();
    print(thumbURL);
    return {
      "url": url,
      "fileName": path.basename(file.path),
      "fileSize": file.lengthSync().toString(),
      "thumbnail": thumbURL
    };
  }

  Future<String> uploadProfile(File file, String phoneNumber) async {
    var uploadTask = _firebaseStorage
        .ref()
        .child("$phoneNumber.${file.path.split('.').last}")
        .putFile(file);

    uploadTask.events.listen((event) {
      fileProgress = event.snapshot.bytesTransferred.toDouble();
    });

    var storageRef = await uploadTask.onComplete;
    return await storageRef.ref.getDownloadURL();
  }
}

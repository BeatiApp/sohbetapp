import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:sohbetapp/utilities/sensitive_constants.dart';

class EncryptionService {
  static String generateMD5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static bool checkMD5EqualTo(String md5hash, String input) {
    return md5hash == md5.convert(utf8.encode(input)).toString();
  }

  static String _getModifiedPasswordFrom(String initialKey) {
    var paddingNeeded = 32 - initialKey.length;

    return paddingNeeded == 0
        ? initialKey
        : initialKey + developerKey.substring(0, paddingNeeded);
  }

  static String _getModifiedIvPasswordFrom(String initialIV) {
    //cGF9jhKhoYFHKowp3jFbAtZqeRBcxJ2L => id

    initialIV =
        initialIV.substring(0, min(10, initialIV.length)); // cGF9jhKhoY => iv
    var paddingNeeded = 16 - initialIV.length; // 6
    return initialIV +
        developerKey.substring(
            0, paddingNeeded); // cGF9jhKhoY + dAYA4o = cGF9jhKhoYdAYA4o
  }

  static String decrypt(String ivPassword, String password, String base64Data) {
    final decryptionPass = _getModifiedPasswordFrom(password);
    final iv = IV.fromUtf8(_getModifiedIvPasswordFrom(ivPassword));

    final encrypter = Encrypter(
      AES(
        Key.fromUtf8(decryptionPass),
        mode: AESMode.cbc,
      ),
    );

    return encrypter.decrypt64(base64Data, iv: iv);
  }

  static String encrypt(String ivPassword, String password, String data) {
    final encryptionPassword = _getModifiedPasswordFrom(password);
    final iv = IV.fromUtf8(_getModifiedIvPasswordFrom(ivPassword));

    final encrypter = Encrypter(
      AES(
        Key.fromUtf8(encryptionPassword),
        mode: AESMode.cbc,
      ),
    );

    return encrypter.encrypt(data, iv: iv).base64;
  }
}

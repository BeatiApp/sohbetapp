import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User get currentUser => _auth.currentUser;

  Future signInWithPhone(String phoneNumber, BuildContext context) async {
    var beforeUser = await _auth.signInWithPhoneNumber(phoneNumber);
    User user;
    _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) async {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            animType: CoolAlertAnimType.slideInUp,
            confirmBtnText: "TAMAM",
            title: "Doğrulama Başarılı oldu!",
          );
        },
        verificationFailed: (error) async {
          await CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              animType: CoolAlertAnimType.slideInUp,
              confirmBtnText: "TAMAM",
              title: "Doğrulama Başarısız Oldu!",
              text:
                  "Maalesef doğrulama işleminiz başarısız oldu. Hata Kodu: ${error.code}");
        },
        codeSent: (verificationId, forceResendingToken) {
          print(forceResendingToken);
          return showDialog(
            context: context,
            builder: (context) {
              final TextEditingController _pinPutController =
                  TextEditingController();
              final FocusNode _pinPutFocusNode = FocusNode();
              BoxDecoration pinPutDecoration = BoxDecoration(
                border: Border.all(color: Colors.deepPurpleAccent),
                borderRadius: BorderRadius.circular(15.0),
              );

              return AlertDialog(
                title: Text("Telefon Numaranı Doğrula"),
                content: Container(
                  child: Column(
                    children: [
                      Text(
                          "Lütfen $phoneNumber numaralı telefona gelen doğrulama kodunu giriniz"),
                      SizedBox(
                        height: 40,
                      ),
                      PinPut(
                        fieldsCount: 5,
                        onSubmit: (String pin) {
                          beforeUser.confirm(pin).then((value) {
                            user = value.user;
                          });

                          Navigator.pop(context);

                          return user;
                        },
                        focusNode: _pinPutFocusNode,
                        controller: _pinPutController,
                        submittedFieldDecoration: pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        selectedFieldDecoration: pinPutDecoration,
                        followingFieldDecoration: pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.deepPurpleAccent.withOpacity(.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        beforeUser
                            .confirm(_pinPutController.text)
                            .then((value) {
                          user = value.user;
                        });

                        Navigator.pop(context);

                        return user;
                      },
                      child: Text("Doğrula"))
                ],
              );
            },
          );
        },
        codeAutoRetrievalTimeout: null);
  }
}

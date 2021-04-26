import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/core/services/services.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/screens/sohbet_main.dart';

import 'package:sohbetapp/widgets/custom-shape.dart';
import 'package:sohbetapp/widgets/custom_textform_field.dart';
import 'package:sohbetapp/widgets/auth/privacy-policy.dart';
import 'package:sohbetapp/widgets/responsive_widget.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool checkBoxValue = false;
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ImagePicker imagePicker = ImagePicker();
  String myPhoneNumber;
  bool loadingState = false;
  MessagingService messagingService = getIt<MessagingService>();
  File image;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  GlobalKey<ScaffoldState> scKey = GlobalKey<ScaffoldState>();
  void initState() {
    getCurrentProfile();
    super.initState();
  }

  getCurrentProfile() async {
    SmsAutoFill autoFill = SmsAutoFill();
    String phoneNumber = await autoFill.hint;
    setState(() {
      myPhoneNumber = phoneNumber;
    });
  }

  void logInWithEmailAndPassword() async {
    if (formKey.currentState.validate() &&
        passwordController.text == rePasswordController.text &&
        image != null &&
        checkBoxValue == true) {
      firebaseAuth.verifyPhoneNumber(
          phoneNumber: myPhoneNumber,
          verificationCompleted: (cred) async {
            setState(() {
              loadingState = true;
            });
            UserCredential userCredential =
                await firebaseAuth.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text);

            User user = userCredential.user;
            StorageReference firebaseStorageRef =
                FirebaseStorage.instance.ref().child("profiles/${user.uid}");
            StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);
            var token = await messagingService.getUserToken();

            await uploadTask.onComplete.then((value) async {
              String profileURL = await value.ref.getDownloadURL();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set({
                "state": "online",
                "email": user.email,
                "phoneNumber": myPhoneNumber,
                "username": _userNameController.text,
                "profileImage": profileURL,
                "token": token,
                "usernameQuery": setSearchParam(_userNameController.text),
                "lastSeenHour": DateTime.now()
              }).then((value) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => SohbetMain()));
              });
            });
          },
          verificationFailed: (e) {
            scKey.currentState.showSnackBar(SnackBar(
                content: Text(e.phoneNumber +
                    " gönderilen kod geçersiz durumda. Daha sonra tekrar deneyin.")));
          },
          codeSent: (str, i) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("SMS gönderildi"),
                content: Text(
                    "Doğrulama SMS'i telefonunuza gönderildi. 60 saniye içinde otomatik doğrulama yapılmasını bekleyiniz."),
              ),
            );
          },
          timeout: Duration(seconds: 120),
          codeAutoRetrievalTimeout: (error) {
            debugPrint(error);
          });
    } else {
      scKey.currentState.showSnackBar(SnackBar(
        content: Text("Tüm bilgileri eksiksiz doldurduğunuzdan emin olun"),
      ));
    }
  }

  setSearchParam(String caseNumber) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Scaffold(
      key: scKey,
      body: Container(
        height: _height,
        width: _width,
        margin: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              clipShape(),
              form(),
              acceptTermsTextRow(),
              SizedBox(
                height: _height / 35,
              ),
              button(),
              signInTextRow(),
              SizedBox(
                height: _height / 35,
              ),
              Image.asset("assets/logos/logo-type.png", width: _width / 2)
            ],
          ),
        ),
      ),
    );
  }

  Widget clipShape() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height / 8
                  : (_medium ? _height / 7 : _height / 6.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _large
                  ? _height / 12
                  : (_medium ? _height / 11 : _height / 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: _height / 5.5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  spreadRadius: 0.0,
                  color: Colors.black26,
                  offset: Offset(1.0, 10.0),
                  blurRadius: 20.0),
            ],
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
              onTap: () async {
                PickedFile pickedFile =
                    await imagePicker.getImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    image = File(pickedFile.path);
                  });
                }
              },
              child: image == null
                  ? Icon(
                      Icons.add_a_photo,
                      size: _large ? 40 : (_medium ? 33 : 31),
                      color: Theme.of(context).primaryColor,
                    )
                  : CircleAvatar(
                      radius: 80,
                      backgroundImage: FileImage(image),
                    )),
        ),
//        Positioned(
//          top: _height/8,
//          left: _width/1.75,
//          child: Container(
//            alignment: Alignment.center,
//            height: _height/23,
//            padding: EdgeInsets.all(5),
//            decoration: BoxDecoration(
//              shape: BoxShape.circle,
//              color:  Colors.orange[100],
//            ),
//            child: GestureDetector(
//                onTap: (){
//                  print('Adding photo');
//                },
//                child: Icon(Icons.add_a_photo, size: _large? 22: (_medium? 15: 13),)),
//          ),
//        ),
      ],
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0, right: _width / 12.0, top: _height / 20.0),
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            firstNameTextFormField(),
            SizedBox(height: _height / 60.0),
            emailTextFormField(),
            SizedBox(height: _height / 60.0),
            passwordTextFormField(),
            SizedBox(height: _height / 60.0),
            rePasswordTextFormField(),
            SizedBox(height: _height / 60.0),
          ],
        ),
      ),
    );
  }

  Widget firstNameTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.text,
      textEditingController: _userNameController,
      icon: Icons.person,
      hint: "İsim",
    );
  }

  Widget emailTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.emailAddress,
      textEditingController: emailController,
      icon: Icons.email,
      hint: "Mail Adresi",
    );
  }

  Widget passwordTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.text,
      obscureText: true,
      textEditingController: passwordController,
      icon: Icons.lock,
      hint: "Şifre",
    );
  }

  Widget rePasswordTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.text,
      obscureText: true,
      textEditingController: rePasswordController,
      icon: Icons.lock_outlined,
      hint: "Şifre Yeniden",
    );
  }

  Widget acceptTermsTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Checkbox(
              activeColor: Theme.of(context).primaryColor,
              value: checkBoxValue,
              onChanged: (bool newValue) {
                setState(() {
                  checkBoxValue = newValue;
                });
              }),
          Text(
            "Tüm ",
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 12 : (_medium ? 11 : 10)),
          ),
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => privacyPolicy(context),
              );
            },
            child: Text(
              "şartları ",
              style: GoogleFonts.roboto(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: _large ? 12 : (_medium ? 11 : 10)),
            ),
          ),
          Text(
            "okudum ve kabul ediyorum",
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 12 : (_medium ? 11 : 10)),
          ),
        ],
      ),
    );
  }
  //

  Widget button() {
    return RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () async {
        logInWithEmailAndPassword();
      },
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
//        height: _height / 20,
        width: _large ? _width / 4 : (_medium ? _width / 3.75 : _width / 3.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'KAYIT OL',
          style:
              GoogleFonts.roboto(fontSize: _large ? 14 : (_medium ? 12 : 10)),
        ),
      ),
    );
  }

  Widget socialIconsRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 80.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/logos/googlelogo.png"),
          ),
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/logos/fblogo.jpg"),
          ),
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/logos/twitterlogo.jpg"),
          ),
        ],
      ),
    );
  }

  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Hesabın var mı?",
            style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              print("Routing to Sign up screen");
            },
            child: Text(
              "Giriş Yap",
              style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                  fontSize: 19),
            ),
          )
        ],
      ),
    );
  }
}

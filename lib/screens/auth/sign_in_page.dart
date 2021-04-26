import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sohbetapp/core/services/validator_service.dart';
import 'package:sohbetapp/screens/auth/signup.dart';
import 'package:sohbetapp/screens/sohbet_main.dart';
import 'package:sohbetapp/widgets/custom-shape.dart';
import 'package:sohbetapp/widgets/custom_textform_field.dart';
import 'package:sohbetapp/widgets/responsive_widget.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;
  bool obscure = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey();
  Validator validator = Validator();
  TextEditingController _mailController = TextEditingController();
  GlobalKey<ScaffoldState> scKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Scaffold(
      key: scKey,
      body: Material(
        child: Container(
          height: _height,
          width: _width,
          padding: EdgeInsets.only(bottom: 5),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                clipShape(),
                welcomeTextRow(),
                signInTextRow(),
                form(),
                forgetPassTextRow(),
                SizedBox(height: _height / 12),
                button(),
                signUpTextRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget clipShape() {
    //double height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height / 4
                  : (_medium ? _height / 3.75 : _height / 3.5),
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
                  ? _height / 4.5
                  : (_medium ? _height / 4.25 : _height / 4),
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
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(
              top: _large
                  ? _height / 30
                  : (_medium ? _height / 25 : _height / 20)),
          child: Image.asset(
            'assets/logos/logo.png',
            height: _height / 3.5,
            width: _width / 3.5,
          ),
        ),
      ],
    );
  }

  Widget welcomeTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Hoşgeldin",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: _large ? 60 : (_medium ? 50 : 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Text(
            "sohbetapp hesabınıza giriş yapınız.",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w300,
              fontSize: _large ? 20 : (_medium ? 17.5 : 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0, right: _width / 12.0, top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            emailTextFormField(),
            SizedBox(height: _height / 40.0),
            passwordTextFormField(),
          ],
        ),
      ),
    );
  }

  Widget emailTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.emailAddress,
      textEditingController: emailController,
      validate: (val) {
        return validator.validateEmail(val);
      },
      icon: Icons.email,
      hint: "Mail Adersiniz...",
    );
  }

  Widget passwordTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.emailAddress,
      textEditingController: passwordController,
      icon: Icons.lock,
      validate: (val) {
        return validator.validatePasswordLength(val);
      },
      obscureText: obscure,
      obscureIcon: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: IconButton(
          icon: Icon(obscure == true
              ? Icons.remove_red_eye_outlined
              : FontAwesomeIcons.eyeSlash),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        ),
      ),
      hint: "Şifre",
    );
  }

  Widget forgetPassTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Şifreni mi unuttun?",
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 14 : (_medium ? 12 : 10)),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () async {
              GlobalKey<FormState> _formKey = GlobalKey<FormState>();
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Şifre Yenile"),
                  content: Form(
                    key: _formKey,
                    child: CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      textEditingController: _mailController,
                      validate: (val) {
                        return validator.validateEmail(val);
                      },
                      icon: Icons.email,
                      hint: "Mail Adersiniz...",
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          print(_mailController.text);
                          if (_formKey.currentState.validate()) {
                            await firebaseAuth.sendPasswordResetEmail(
                                email: _mailController.text);
                            scKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "Email Adresinizden şifrenizi sıfırlayabilirsiniz.")));
                            await Future.delayed(Duration(seconds: 5));
                            Navigator.pop(context);
                          }
                        },
                        child: Text("GÖNDER"))
                  ],
                ),
              );
            },
            child: Text(
              "Yenile",
              style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
    );
  }

  Widget button() {
    return RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () async {
        if (_key.currentState.validate()) {
          print("Routing to your account");
          await firebaseAuth.signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

          scKey.currentState
              .showSnackBar(SnackBar(content: Text('Giriş Başarılı')));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SohbetMain(),
              ));
        } else {
          scKey.currentState
              .showSnackBar(SnackBar(content: Text("Giriş Yapılamadı")));
        }
      },
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
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
        child: Text('GIRIS YAP',
            style: GoogleFonts.roboto(
                fontSize: _large ? 14 : (_medium ? 12 : 10))),
      ),
    );
  }

  Widget signUpTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 120.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Hesabın yok mu ?",
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 14 : (_medium ? 12 : 10)),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignUpScreen()));
              print("Routing to Sign up screen");
            },
            child: Text(
              "Kayıt Ol",
              style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).accentColor,
                  fontSize: _large ? 19 : (_medium ? 17 : 15)),
            ),
          )
        ],
      ),
    );
  }
}

// class SignInPage extends StatefulWidget {
//   const SignInPage({Key key}) : super(key: key);

//   @override
//   _SignInPageState createState() => _SignInPageState();
// }

// class _SignInPageState extends State<SignInPage> {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'Sohbete Kaydol',
//           style: GoogleFonts.roboto(fontFamily: "", fontSize: 30),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(8),
//           child: loadingState == true
//               ? Center(child: CircularProgressIndicator())
//               : Form(
//                   key: formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Text(
//                         "Profil Resmi Seç (Opsiyonel)",
//                         style: GoogleFonts.roboto(fontFamily: "", fontSize: 20),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       CupertinoButton(
//                           child: image == null
//                               ? CircleAvatar(
//                                   radius: 40,
//                                   backgroundColor: Colors.grey,
//                                   child: Center(
//                                     child: Icon(
//                                       Icons.camera_alt_outlined,
//                                       color: Colors.grey[850],
//                                     ),
//                                   ),
//                                 )
//                               : CircleAvatar(
//                                   radius: 40,
//                                   backgroundImage: FileImage(image)),
//                           onPressed: () async {
//                             PickedFile pickedFile = await imagePicker.getImage(
//                                 source: ImageSource.gallery);
//                             if (pickedFile != null) {
//                               setState(() {
//                                 image = File(pickedFile.path);
//                               });
//                             }
//                           }),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       CardTextField(
//                         labelText: "İsim - Soyisim",
//                         iconData: Icons.person_pin_circle_rounded,
//                         controller: _userNameController,
//                         keyboardType: TextInputType.name,
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       CardTextField(
//                         controller: emailController,
//                         iconData: Icons.email,
//                         labelText: "Mail Adresi",
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       CardTextField(
//                         labelText: "Şifre",
//                         iconData: Icons.lock,
//                         controller: passwordController,
//                         keyboardType: TextInputType.text,
//                         obscureText: true,
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       CardTextField(
//                         obscureText: true,
//                         controller: rePasswordController,
//                         iconData: Icons.lock_outlined,
//                         labelText: "Şifre Tekrar",
//                       ),
//                       SizedBox(
//                         height: 30,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.privacy_tip_outlined),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           Text(
//                             "Gizlilik Politikası",
//                             style:
//                                 GoogleFonts.roboto(decoration: TextDecoration.underline),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Container(
//                         height: 50,
//                         child: RaisedButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20)),
//                             color: Theme.of(context).accentColor,
//                             child: Text(
//                               'Sohbete Basla!',
//                               style: GoogleFonts.roboto(fontFamily: "", fontSize: 20),
//                             ),
//                             onPressed: () async {
//                               logInWithEmailAndPassword();
//                             }),
//                       )
//                     ],
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }

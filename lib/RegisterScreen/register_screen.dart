import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spacecorp_messanger/HightOrderComponents/simple_btn.dart';
import 'package:spacecorp_messanger/HightOrderComponents/simple_password_input.dart';
import 'package:spacecorp_messanger/HightOrderComponents/simple_text_input.dart';
import 'package:spacecorp_messanger/constant.dart';
import 'package:spacecorp_messanger/Authscreen/auth_screen.dart';
import 'package:spacecorp_messanger/services/auth.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  double inputHeight = 35;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController positionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    cleanController() {
      emailController.clear();
      passwordController.clear();
      displayNameController.clear();
      positionController.clear();
    }

    registerUser() {
      AuthMedthods().registerWithEmailandPassword(
        context,
        emailController.text,
        passwordController.text,
        displayNameController.text,
        positionController.text,
      );
      cleanController();
    }

    getBack() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthScreen()));
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: spaceGradient,
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(-3, 6),
                    blurRadius: 4,
                    spreadRadius: 6,
                    color: Colors.black.withOpacity(0.2),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 50,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    width: size.width * 0.8,
                    height: size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Register form",
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SimpleTextInput(
                          hintText: "Email",
                          controller: emailController,
                          height: inputHeight,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SimplePasswordInput(
                          hintText: "Password",
                          controller: passwordController,
                          height: inputHeight,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SimpleTextInput(
                          hintText: "Display name",
                          controller: displayNameController,
                          height: inputHeight,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SimpleTextInput(
                          hintText: "Position",
                          controller: positionController,
                          height: inputHeight,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SimpleButton(
                          buttonTitle: "Register",
                          onTap: registerUser,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SimpleButton(
                          buttonTitle: "Return",
                          onTap: getBack,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

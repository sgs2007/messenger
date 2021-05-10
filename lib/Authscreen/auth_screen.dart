import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spacecorp_messanger/HightOrderComponents/simple_btn.dart';
import 'package:spacecorp_messanger/HightOrderComponents/simple_password_input.dart';
import 'package:spacecorp_messanger/HightOrderComponents/simple_text_input.dart';
import 'package:spacecorp_messanger/RegisterScreen/register_screen.dart';
import 'package:spacecorp_messanger/constant.dart';
import 'package:spacecorp_messanger/services/auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double inputWidth = size.width * 0.7;
    double inputHeight = 40;

    signIn() {
      AuthMedthods().signInWithUserData(
          emailController.text, passwordController.text, context);
    }

    register() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => RegisterScreen()));
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
                    color: Colors.black.withOpacity(0.1),
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
                      vertical: 20,
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "SpaceCorp Chat",
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.chat,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        SimpleTextInput(
                          hintText: "Email",
                          controller: emailController,
                          width: inputWidth,
                          height: inputHeight,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SimplePasswordInput(
                          hintText: "Password",
                          controller: passwordController,
                          width: inputWidth,
                          height: inputHeight,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        SimpleButton(
                          buttonTitle: "Sign in",
                          onTap: signIn,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        SimpleButton(
                          buttonTitle: "Sign up",
                          onTap: register,
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

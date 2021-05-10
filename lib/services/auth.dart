import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacecorp_messanger/HomeScreen/home_screen.dart';
import 'package:spacecorp_messanger/Authscreen/auth_screen.dart';
import 'package:spacecorp_messanger/HomeScreen/home_screen2.dart';
import 'package:spacecorp_messanger/helper_function/sharedpref_helper.dart';
import 'package:spacecorp_messanger/services/database.dart';

class AuthMedthods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User> getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithUserData(
      String email, String password, BuildContext context) async {
    UserCredential result =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    User user = result.user;

    if (user != null) {
      var userInformation = await DataBaseMethods().getCurrentUser(user.uid);

      userInformation.data().forEach((key, value) async {
        switch (key) {
          case "username":
            await SharedprefenceHelper().saveUserName(value);
            break;
          case "position":
            await SharedprefenceHelper().saveUserPosition(value);
            break;
        }
      });

      await DataBaseMethods().updateStatus(user.uid, "online");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen2()));
    }
  }

  registerWithEmailandPassword(BuildContext context, String email,
      String password, String displayName, String position) async {
    bool errorsChecking = true;
    String errorType = "";
    String errorMessage = "";

    if (email == "" || password == "" || displayName == "" || position == "") {
      errorsChecking = false;
      errorType = "Empty fields. ";
      String emptyinputs = "";

      Map<String, dynamic> emptyField = {
        "email": email,
        "password": password,
        "displayName": displayName,
        "position": position,
      };

      emptyField.forEach((key, value) {
        if (value == "") {
          if (key == "position") {
            emptyinputs += "$key. ";
          } else {
            emptyinputs += "$key, ";
          }
        }
      });
      errorMessage = "You didn't fill next input: $emptyinputs";
    }

    if (password.length < 6) {
      errorsChecking = false;
      if (errorType != "") {
        errorType += "Incorrect password lenght. ";
        errorMessage += "Password leght should be more then 6 symbols. ";
      } else {
        errorType = "Incorrect password lenght. ";
        errorMessage = "Password leght should be more then 6 symbols. ";
      }
    }

    if (!errorsChecking) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(errorType),
            content: Text(errorMessage),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok")),
            ],
          );
        },
      );
    } else {
      User user = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        List<String> splitString = displayName.split(" ");
        List<String> indexList = [];

        for (int i = 0; i < splitString.length; i++) {
          for (var j = 1; j < splitString[i].length + 1; j++) {
            indexList.add(splitString[i].substring(0, j).toLowerCase());
          }
        }
        Map<String, dynamic> userInfo = {
          "username": user.email.replaceAll("@gmail.com", ""),
          "name": displayName,
          "position": position,
          "status": "offline",
          "searchIndex": indexList,
        };

        await DataBaseMethods().addUserInfo(user.uid, userInfo);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AuthScreen()));
      }
    }
  }

  logOut() async {
    await DataBaseMethods().updateStatus(auth.currentUser.uid, "offline");
    await auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

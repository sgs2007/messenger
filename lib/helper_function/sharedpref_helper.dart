import 'package:shared_preferences/shared_preferences.dart';

class SharedprefenceHelper {
  static String userNameKey = "USERNAMEKEY";
  static String userPositionKey = "USERPOSITIONKEY";

  Future<bool> saveUserName(String username) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userNameKey, username);
  }

  Future<bool> saveUserPosition(String position) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userPositionKey, position);
  }

  Future<String> getUserName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userNameKey);
  }

  Future<String> getUserPosition() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userPositionKey);
  }
}

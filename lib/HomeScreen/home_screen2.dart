import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spacecorp_messanger/Authscreen/auth_screen.dart';
import 'package:spacecorp_messanger/HomeScreen/components/person_card.dart';
import 'package:spacecorp_messanger/constant.dart';
import 'package:spacecorp_messanger/main.dart';
import 'package:spacecorp_messanger/services/auth.dart';
import 'package:spacecorp_messanger/services/database.dart';
import 'package:spacecorp_messanger/services/notifications.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({Key key}) : super(key: key);

  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> with WidgetsBindingObserver {
  bool darkMode = true;
  bool isSearch = false;
  String searchString;
  TextEditingController searchTextEditingController = TextEditingController();
  Stream userList, searchUserList;

  Notifications firebase;

//Clear input after press clear button
  clearSearchInput() {
    setState(() {
      searchTextEditingController.clear();
      searchString = "";
      isSearch = false;
    });
  }

//Get users list for Stream/ListView builder
  getUserList() async {
    userList = await DataBaseMethods().getUsersList();
  }

//Get needed user
  getSearchedUser() async {
    searchUserList = await DataBaseMethods().getUserIndex(searchString);
  }

  handleAsync() async {
    String token = await firebase.getToken();
    AuthMedthods().getCurrentUser().then((user) =>
        {DataBaseMethods().updateLogHistoryAndToken(user.uid, token)});
    print(token);
  }

  @override
  void initState() {
    super.initState();
    firebase = Notifications();
    firebase.initialize();
    handleAsync();
    getUserList();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      print("detached");
      AuthMedthods().logOut();
    }
    if (state == AppLifecycleState.inactive) {
      print("absent");
      AuthMedthods().getCurrentUser().then((value) {
        DataBaseMethods().updateStatus(value.uid, "absent");
      });
    }
    if (state == AppLifecycleState.paused) {
      print("paused");
      AuthMedthods().getCurrentUser().then((value) {
        DataBaseMethods().updateStatus(value.uid, "offline");
      });
    }
    if (state == AppLifecycleState.resumed) {
      print("resume");
      AuthMedthods().getCurrentUser().then((value) {
        DataBaseMethods().updateStatus(value.uid, "online");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    logOut() {
      AuthMedthods().logOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthScreen()));
    }

    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: logOut,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Space Corp",
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                logOut();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
          backgroundColor: kContentColorDarkTheme,
        ),
        body: Container(
          width: size.width,
          height: size.height,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 20,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                width: size.width,
                height: size.height * 0.1,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchTextEditingController,
                                  style: TextStyle(color: Colors.black),
                                  onChanged: (value) {
                                    setState(() {
                                      searchString = value.toLowerCase();
                                      if (value == null || value.trim() == "") {
                                        isSearch = false;
                                      } else {
                                        isSearch = true;
                                      }
                                    });
                                  },
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              !isSearch
                                  ? Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        if (searchString != "" ||
                                            searchString.trim() != "") {
                                          clearSearchInput();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.clear_sharp,
                                        color: Colors.white,
                                        size: 27,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    top: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: StreamBuilder(
                    stream: (searchString == null || searchString.trim() == "")
                        ? FirebaseFirestore.instance
                            .collection("users")
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection("users")
                            .where("searchIndex", arrayContains: searchString)
                            .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.done:
                          return Center(
                            child: Text("Data loaded"),
                          );
                        default:
                          return ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot ds = snapshot.data.docs[index];
                                return PersonCard(
                                  userName: ds["username"],
                                  name: ds["name"],
                                  position: ds["position"],
                                  status: ds["status"],
                                  mode: darkMode,
                                );
                              });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spacecorp_messanger/Authscreen/auth_screen.dart';
import 'package:spacecorp_messanger/HomeScreen/components/person_card.dart';
import 'package:spacecorp_messanger/constant.dart';
import 'package:spacecorp_messanger/services/auth.dart';
import 'package:spacecorp_messanger/services/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearching = false;
  bool darkMode = true;
  TextEditingController searchTextEditingController = TextEditingController();
  Stream usersListStream, searchingUsersListStream;

  getUserList() async {
    usersListStream = await DataBaseMethods().getUsersList();
    setState(() {});
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    searchingUsersListStream =
        await DataBaseMethods().getUser(searchTextEditingController.text);
    setState(() {});
  }

  changeMode() {
    setState(() {
      darkMode = !darkMode;
    });
  }

  @override
  void initState() {
    getUserList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logOut() {
      AuthMedthods().logOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthScreen()));
    }

    Size size = MediaQuery.of(context).size;

    Widget chatRoomsList() {
      return StreamBuilder(
          stream: usersListStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return PersonCard(
                        userName: ds["name"],
                        position: ds["position"],
                        status: ds["status"],
                        mode: darkMode,
                      );
                    })
                : Center(
                    child: CircularProgressIndicator(),
                  );
          });
    }

    Widget searchUsersList() {
      return StreamBuilder(
          stream: searchingUsersListStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return PersonCard(
                        userName: ds["name"],
                        position: ds["position"],
                        status: ds["status"],
                        mode: darkMode,
                      );
                    })
                : Center(
                    child: CircularProgressIndicator(),
                  );
          });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            changeMode();
          },
          icon: darkMode
              ? Icon(Icons.wb_sunny_outlined)
              : Icon(Icons.nights_stay_outlined),
        ),
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
        backgroundColor:
            darkMode ? Colors.greenAccent[700] : kContentColorDarkTheme,
      ),
      body: Container(
        width: size.width,
        height: size.height,
        color: darkMode ? kContentColorDarkTheme : Colors.white,
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
                    isSearching
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                isSearching = false;
                                searchTextEditingController.text = "";
                              });
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: darkMode
                              ? Colors.white.withOpacity(0.4)
                              : Colors.black.withOpacity(0.3),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchTextEditingController,
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (searchTextEditingController.text != "") {
                                  onSearchBtnClick();
                                }
                              },
                              icon: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 29,
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
                child: isSearching ? searchUsersList() : chatRoomsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

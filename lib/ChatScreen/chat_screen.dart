import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:spacecorp_messanger/HomeScreen/home_screen2.dart';
import 'package:spacecorp_messanger/constant.dart';
import 'package:spacecorp_messanger/helper_function/sharedpref_helper.dart';
import 'package:spacecorp_messanger/services/auth.dart';
import 'package:spacecorp_messanger/services/database.dart';

class ChatScreen extends StatefulWidget {
  // final String chatWithUsername, username;
  // final bool darkMode;
  ChatScreen({
    Key key,
    @required this.username,
    @required this.name,
  }) : super(key: key);

  final username, name;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  String chatRoomId, messageId = "";
  Stream messagesStream;
  String myUsername;
  TextEditingController messageTextEditingController = TextEditingController();
  ScrollController _listScrollController = ScrollController();

  //Get chatroom id
  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  getMyInfo() async {
    myUsername = await SharedprefenceHelper().getUserName();
    chatRoomId = getChatRoomId(myUsername, widget.username);
  }

  getMessagesStream() async {
    messagesStream = await DataBaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  addMessage() {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;
      var date = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "type": "message",
        "message": message,
        "date": date,
        "sendBy": myUsername,
        "readed": "no",
      };

      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DataBaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap, widget.username);
      messageId = "";
      messageTextEditingController.clear();
    }
  }

  addImage(BuildContext context, String type) async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;
    String refChild = "";
    PermissionStatus permission_status;

    if (type == "galerry") {
      await Permission.photos.request();
      permission_status = await Permission.photos.status;
    } else {
      await Permission.camera.request();
      permission_status = await Permission.camera.status;
    }

    if (permission_status.isGranted) {
      if (type == "galerry") {
        image = await _picker.getImage(source: ImageSource.gallery);
        refChild = "images/galerry/";
      } else {
        image = await _picker.getImage(source: ImageSource.camera);
        refChild = "images/camera/";
      }

      if (image != null) {
        var file = File(image.path);

        if (messageId == "") {
          messageId = randomAlphaNumeric(12);
        }

        var snapshot =
            await _storage.ref().child(refChild + messageId).putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        var date = DateTime.now();

        Map<String, dynamic> messageInfoMap = {
          "type": "picture",
          "purl": downloadUrl,
          "date": date,
          "sendBy": myUsername,
          "readed": "no",
        };

        DataBaseMethods()
            .addMessage(chatRoomId, messageId, messageInfoMap, widget.username);
        messageId = "";
      } else {
        print("No path received");
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"),
                ),
              ],
              title: Text("Permission for this action was denied"),
              content: Text(
                  "Please go to the settings and grant permission for this action."),
            );
          });
    }
  }

  firstLoaded() async {
    await getMyInfo();
    await getMessagesStream();
  }

  @override
  void initState() {
    super.initState();
    firstLoaded();
    WidgetsBinding.instance.addObserver(this);
  }

  Widget chatMessageTitle(String id, Map<String, dynamic> data) {
    var fireBaseTimeStamp = DateTime.fromMicrosecondsSinceEpoch(
        data["date"].microsecondsSinceEpoch);
    var date = formatDate(
        fireBaseTimeStamp, [HH, ':', nn, ' ', yyyy, '-', mm, '-', dd]);

    bool unreaded = data["readed"] == "no" ? true : false;

    return Row(
      mainAxisAlignment: data["sendBy"] == myUsername
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () {
              if (data["readed"] == "no" && data["sendBy"] != myUsername) {
                DataBaseMethods()
                    .markMessageAsReaded(chatRoomId, id, myUsername);
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomRight: data["sendBy"] == myUsername
                      ? Radius.circular(0)
                      : Radius.circular(25),
                  bottomLeft: data["sendBy"] == myUsername
                      ? Radius.circular(25)
                      : Radius.circular(0),
                ),
                color: data["sendBy"] == myUsername
                    ? kContentColorDarkTheme.withOpacity(0.8)
                    : kContentColorDarkTheme,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
              child: data["type"] == "message"
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          data["message"],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Image.network(
                            data["purl"],
                            fit: BoxFit.fill,
                            loadingBuilder: (context, child, loadingProgress) {
                              return loadingProgress == null
                                  ? child
                                  : Center(
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          backgroundColor:
                                              kContentColorDarkTheme
                                                  .withOpacity(0.6),
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        data["sendBy"] != myUsername && unreaded
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[400],
                  borderRadius: BorderRadius.circular(5),
                ),
              )
            : Container(),
      ],
    );
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
      AuthMedthods().logOut();
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      print("paused");
      AuthMedthods().getCurrentUser().then((value) {
        DataBaseMethods().updateStatus(value.uid, "absent");
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
    Size size = MediaQuery.of(context).size;
    returnBack() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen2()),
      );
    }

    return WillPopScope(
      onWillPop: returnBack,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kContentColorDarkTheme,
          centerTitle: true,
          title: Text(
            widget.name,
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              returnBack();
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: StreamBuilder(
                    stream: messagesStream,
                    builder: (context, snapshot) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        if (_listScrollController.hasClients) {
                          _listScrollController.jumpTo(
                              _listScrollController.position.maxScrollExtent +
                                  200);
                        } else {
                          setState(() => null);
                        }
                      });
                      return snapshot.hasData
                          ? ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              controller: _listScrollController,
                              itemBuilder: (context, index) {
                                DocumentSnapshot ds = snapshot.data.docs[index];
                                var data = ds.data();
                                return chatMessageTitle(ds.id, data);
                              })
                          : Center(
                              child: CircularProgressIndicator(),
                            );
                    },
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                width: size.width,
                height: 90,
                decoration: BoxDecoration(color: kContentColorDarkTheme),
                child: Container(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.mic_sharp,
                          color: Colors.deepPurple[300],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            color: Colors.grey[200],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () => addImage(context, "galerry"),
                                  icon: Icon(Icons.photo_library_rounded)),
                              IconButton(
                                onPressed: () => addImage(context, "camera"),
                                icon: Icon(Icons.camera_alt_rounded),
                                alignment: Alignment.centerLeft,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messageTextEditingController,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: "Type message",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  addMessage();
                                },
                                icon: Icon(Icons.send_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

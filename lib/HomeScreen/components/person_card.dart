import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spacecorp_messanger/ChatScreen/chat_screen.dart';
import 'package:spacecorp_messanger/constant.dart';
import 'package:spacecorp_messanger/helper_function/sharedpref_helper.dart';
import 'package:spacecorp_messanger/services/database.dart';

class PersonCard extends StatefulWidget {
  PersonCard({
    Key key,
    this.userName,
    this.position,
    this.status,
    this.name,
    @required this.mode,
  }) : super(key: key);

  final String userName, name, position, status;
  bool mode;

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  String chatRoomId, myUsername;
  //Get/create chatroom id
  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  preLoader() async {
    myUsername = await SharedprefenceHelper().getUserName();
    chatRoomId = getChatRoomId(myUsername, widget.userName);
    Map<String, dynamic> chatRoomInfoMap = {
      "users": [myUsername, widget.userName],
    };
    DataBaseMethods().getChatRoom(chatRoomId, chatRoomInfoMap);
    setState(() {});
  }

  @override
  void initState() {
    preLoader();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Check if chatroom already exist (if not create if yes just return true).After navigate to Chat screen.
    openChatroom() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            username: widget.userName,
            name: widget.name,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        openChatroom();
      },
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: widget.status != "offline" && widget.status != "absent"
                ? Colors.green
                : widget.status != "absent"
                    ? Colors.grey[400]
                    : Colors.orange[300],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 36,
          ),
        ),
        title: Text(
          widget.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
          ),
        ),
        subtitle: Text(
          widget.position,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        trailing: Container(
          width: 20,
          height: 20,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .doc(chatRoomId)
                .collection("info")
                .doc(myUsername)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data.data();
                var countUnreadMessage = data["count_unread_message"];
                if (countUnreadMessage != 0) {
                  return CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 10.0,
                    child: Text(
                      countUnreadMessage.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

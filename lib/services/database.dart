import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseMethods {
  Future addUserInfo(String uid, Map<String, dynamic> userInfo) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(userInfo);
  }

  Future updateStatus(String uid, String status) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"status": status});
  }

  Future markMessageAsReaded(
      String chatRoomId, String messageId, String user) async {
    await FirebaseFirestore.instance
        .collection("chatrooms/$chatRoomId/chats")
        .doc(messageId)
        .update({"readed": "yes"});

    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("info")
        .doc(user)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data();

      var counter = data["count_unread_message"];

      if (counter != 0) {
        counter--;
        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(chatRoomId)
            .collection("info")
            .doc(user)
            .update({"count_unread_message": counter});
      }
    }
    return true;
  }

  Future<Stream<QuerySnapshot>> getUsersList() async {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  Future<Stream<QuerySnapshot>> getUser(String name) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: name)
        .snapshots();
  }

  Future getCurrentUser(String userid) async {
    return FirebaseFirestore.instance.collection("users").doc(userid).get();
  }

  Future<Stream<QuerySnapshot>> getUserIndex(String name) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("searchIndex", arrayContains: name)
        .snapshots();
  }

  Future addMessage(String chatRoomId, String messageId, Map messageInfoMap,
      String companion) async {
    //Write message to firestore
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
    //Write info
    var messageType = messageInfoMap["type"];
    var message = messageInfoMap["message"];

    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("info")
        .doc(companion)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data();

      var countUnreadMessage = data["count_unread_message"];

      countUnreadMessage++;

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .collection("info")
          .doc(companion)
          .update({
        "last_message": message,
        "message_type": messageType,
        "count_unread_message": countUnreadMessage
      });
    }

    return true;
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("date", descending: false)
        .snapshots();
  }

  getChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      return true;
    } else {
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);

      var users = chatRoomInfoMap["users"];

      var user1 = users[0];
      Map<String, dynamic> user1_info_map = {
        "user": user1,
        "last_message": "",
        "count_unread_message": 0,
      };
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .collection("info")
          .doc(user1)
          .set(user1_info_map);

      var user2 = users[1];
      Map<String, dynamic> user2_info_map = {
        "user": user2,
        "last_message": "",
        "message_type": "",
        "count_unread_message": 0,
      };
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .collection("info")
          .doc(user2)
          .set(user2_info_map);
      return true;
    }
  }
}

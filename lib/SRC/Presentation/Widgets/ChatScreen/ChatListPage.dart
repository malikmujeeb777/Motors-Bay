import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatPage.dart';
import 'package:intl/intl.dart';


class ChatListPage extends StatefulWidget {

  const ChatListPage({super.key,});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  int _selectedIndex = 2;
  List<Map<String, dynamic>> chats = [];

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      print("User is not logged in");
      return;
    }
    fetchChats();
  }

  Future<void> fetchChats() async {
    var firestore = FirebaseFirestore.instance;

    var chatDocs = await firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    print("Fetched ${chatDocs.docs.length} chats");

    List<Map<String, dynamic>> formattedChats = [];

    for (var chat in chatDocs.docs) {
      print("Processing chat: ${chat.id}");
      String otherUserId = chat['participants'].firstWhere((id) => id != currentUserId);

      print("Current User ID: $currentUserId");
      print("Other User ID: $otherUserId");

      var userDoc = await firestore.collection('users').doc(otherUserId).get();
      print("Fetched user: ${userDoc.data()}");

      // Check if the user document exists
      if (!userDoc.exists) {
        print("User document does not exist for ID: $otherUserId");
        continue; // Skip this chat
      }

      var lastMessageDoc = await firestore
          .collection('chats')
          .doc(chat.id)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      String lastMessage = "No messages yet";
      String timestamp = "";

      if (lastMessageDoc.docs.isNotEmpty) {
        lastMessage = lastMessageDoc.docs.first['text'];
        timestamp = lastMessageDoc.docs.first['timestamp'].toDate().toString();
      }

      formattedChats.add({
        'chatId': chat.id,
        'otherUserId': otherUserId,
        'otherUserName': userDoc['displayName'] ?? "Unknown User",
        'profilePic': userDoc['photoUrl'] ?? "",
        'lastMessage': lastMessage,
        'timestamp': timestamp,
      });
    }

    setState(() {
      chats = formattedChats;
    });
  }


  String formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return "";
    DateTime dateTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();

    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return DateFormat.Hm().format(dateTime); // Show only time
    } else if (dateTime.year == now.year) {
      return DateFormat.MMMd().format(dateTime); // Show "Mar 8"
    } else {
      return DateFormat.yMMMd().format(dateTime); // Show "Dec 20, 2024"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: chat['profilePic'].isNotEmpty
                  ? NetworkImage(chat['profilePic'])
                  : AssetImage('assets/images/gilgit.png') as ImageProvider,
              radius: 24,
            ),
            title: Text(
              chat['otherUserName'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              formatTimestamp(chat['timestamp']),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            tileColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    currentUserId: currentUserId,
                    otherUserId: chat['otherUserId'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
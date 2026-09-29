import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const ChatPage({super.key, required this.currentUserId, required this.otherUserId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  String otherUserName = "User";
  String otherUserProfilePic = "";
  String? chatId; // Chat document ID

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchOtherUserData();
    loadOrCreateChat();
  }

  Future<void> fetchOtherUserData() async {
    // Fetch the other user's details from the 'users' collection
    var userDoc = await firestore.collection('users').doc(widget.otherUserId).get();

    setState(() {
      otherUserName = userDoc['displayName'] ?? "User"; // Adjust field names as needed
      otherUserProfilePic = userDoc['photoUrl'] ?? ""; // Adjust field names as needed
    });
  }

  Future<void> loadOrCreateChat() async {
    // Query to find a chat document where both participants are present
    var chatQuery = await firestore
        .collection('chats')
        .where('participants', arrayContains: widget.currentUserId)
        .get();

    // Find the chat where both participants are present
    for (var chat in chatQuery.docs) {
      if (chat['participants'].contains(widget.otherUserId)) {
        setState(() {
          chatId = chat.id; // Set the chatId
        });
        loadMessages();
        return;
      }
    }

    // If no chat exists, create a new one
    var newChatRef = await firestore.collection('chats').add({
      'participants': [widget.currentUserId, widget.otherUserId],
      'lastMessage': {}, // Initialize lastMessage as empty
    });

    setState(() {
      chatId = newChatRef.id; // Set the chatId
    });
  }

  Future<void> loadMessages() async {
    if (chatId == null) return;

    // Fetch messages from the 'messages' subcollection
    var messagesSnapshot = await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    setState(() {
      messages = messagesSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty || chatId == null) return;

    // Create a new message
    final newMessage = {
      'senderId': widget.currentUserId,
      'text': messageController.text,
      'timestamp': DateTime.now(),
    };

    // Add the message to the 'messages' subcollection
    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage);

    // Update the last message in the chat document
    await firestore.collection('chats').doc(chatId).update({
      'lastMessage': newMessage,
    });

    // Clear the input field and reload messages
    messageController.clear();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: otherUserProfilePic.isNotEmpty
                  ? NetworkImage(otherUserProfilePic)
                  : AssetImage('assets/images/gilgit.png') as ImageProvider,
              radius: 18,
            ),
            SizedBox(width: 10),
            Text(
              otherUserName,
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isMe = message['senderId'] == widget.currentUserId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['text']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
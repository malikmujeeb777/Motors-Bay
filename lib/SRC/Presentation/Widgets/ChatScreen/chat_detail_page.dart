import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:url_launcher/url_launcher.dart';

class ConversationScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  const ConversationScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Check if user is logged in, use fallback ID if not
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        // Show a dialog prompting the user to log in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to send messages'),
            action: SnackBarAction(
              label: 'Log In',
              onPressed: () {
                // Navigate to login screen
                // Add navigation code here
              },
            ),
          ),
        );
        return;
      }
      
      String senderId = currentUser.uid;
      String message = _messageController.text;
      DateTime timestamp = DateTime.now();

      String chatId = senderId.hashCode <= widget.receiverId.hashCode
          ? '$senderId-${widget.receiverId}'
          : '${widget.receiverId}-$senderId';      // Add message to messages subcollection
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': senderId,
        'receiverId': widget.receiverId,
        'message': message,
        'timestamp': timestamp,
        'read': false,
      });
        // First, get current unread counts to make sure we don't reset any counts
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      Map<String, dynamic> unreadCounts = {};
      if (chatDoc.exists) {
        Map<String, dynamic>? chatData = chatDoc.data() as Map<String, dynamic>?;
        if (chatData != null && chatData.containsKey('unreadCount')) {
          unreadCounts = Map<String, dynamic>.from(chatData['unreadCount'] as Map<String, dynamic>);
        }
      }
      
      // Update the unread counts
      unreadCounts[senderId] = 0;  // Current user has read all messages
      unreadCounts[widget.receiverId] = (unreadCounts[widget.receiverId] as int? ?? 0) + 1;  // Increment for receiver
        // Update chat document with last message info
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [senderId, widget.receiverId],
        'lastMessage': message,
        'lastMessageTimestamp': timestamp,
        'unreadCount': unreadCounts,
      }, SetOptions(merge: true));
      
      // Clear the message input field
      _messageController.clear();
    }
  }
    String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "";
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return "";
    }
    
    DateTime now = DateTime.now();
    
    // Same day - show time
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } 
    // Yesterday
    else if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day - 1) {
      return "Yesterday, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    // Same week
    else if (now.difference(dateTime).inDays < 7) {
      List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return "${days[dateTime.weekday - 1]}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    // Same year - show month and day
    else if (dateTime.year == now.year) {
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } 
    // Different year - show month, day and year
    else {
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}";
    }
  }@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markMessagesAsRead();
    });
  }
  
  // Mark messages as read when conversation is opened
  Future<void> markMessagesAsRead() async {
    try {
      // Use currentUser?.uid with a fallback to handle the case when the user isn't logged in
      String senderId = _auth.currentUser?.uid ?? Data.app.token ?? 'guest-user';
      if (senderId == 'guest-user') return;
      
      String chatId = senderId.hashCode <= widget.receiverId.hashCode
          ? '$senderId-${widget.receiverId}'
          : '${widget.receiverId}-$senderId';
      
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$senderId': 0
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Call the receiver using phone app
  void _callReceiver() async {
    try {
      // Try to get receiver's contact information from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.receiverId).get();
      
      String? phoneNumber;
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        phoneNumber = userData['phoneNumber'] ?? userData['phone'];
      }
      
      // Check if we found a valid phone number
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Launch phone app with the number
        final Uri callUri = Uri.parse('tel:$phoneNumber');
        if (await canLaunchUrl(callUri)) {
          await launchUrl(callUri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch phone app"))
          );
        }
      } else {
        // Show message that the phone number is private
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.receiverName}'s phone number is private"))
        );
      }
    } catch (e) {
      print('Error making phone call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to initiate call"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use currentUser?.uid with a fallback to handle the case when the user isn't logged in
    String senderId = _auth.currentUser?.uid ?? Data.app.token ?? 'guest-user';
    String chatId = senderId.hashCode <= widget.receiverId.hashCode
        ? '$senderId-${widget.receiverId}'
        : '${widget.receiverId}-$senderId';

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverImage.isNotEmpty 
                  ? NetworkImage(widget.receiverImage)
                  : null,
              backgroundColor: Colors.grey[200],
              child: widget.receiverImage.isEmpty ? Icon(Icons.person, color: Colors.grey[700]) : null,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.receiverName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),        actions: [
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: () {
              _callReceiver();
            },
          ),
        ],
      ),
      body: Column(
        children: [          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                // Handle error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text('Error loading messages. Please try again.'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Simple refresh mechanism
                          },
                          child: Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                
                // Handle empty state
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 72),
                          SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Send a message to start the conversation!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    bool isMe = messageData['senderId'] == senderId;                    // Mark message as read if it's not from current user
                    if (!isMe && messageData['read'] == false) {
                      // Update message read status
                      _firestore
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(messages[index].id)
                          .update({'read': true});
                    }
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageData['message'],
                              style: TextStyle(color: isMe ? Colors.white : Colors.black),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTimestamp(messageData['timestamp']),
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.black54,
                                    fontSize: 10,
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 3),
                                  Icon(
                                    messageData['read'] == true ? Icons.done_all : Icons.done,
                                    size: 12,
                                    color: messageData['read'] == true ? Colors.white : Colors.white70,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
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
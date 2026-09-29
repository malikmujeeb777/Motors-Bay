import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/ChatScreen/chat_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';

class RealChatScreen extends StatefulWidget {
  const RealChatScreen({super.key});

  @override
  State<RealChatScreen> createState() => _RealChatScreenState();
}

class _RealChatScreenState extends State<RealChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _searchQuery;
  bool _isLoading = true;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  void _initUserId() async {
    // Prioritize Firebase Auth, fall back to Data.app.token
    if (_auth.currentUser != null) {
      _currentUserId = _auth.currentUser!.uid;
    } else if (Data.app.token != null) {
      _currentUserId = Data.app.token!;
    } else {
      _currentUserId = 'guest-user';
      
      // If user is not logged in, prompt them to log in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to see your chats'),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                // Navigate to login screen
                // Add navigation code here
              },
            ),
          ),
        );
      });
    }
    
    // Mark chats as read when this screen opens
    if (_currentUserId != 'guest-user') {
      await _markChatsAsViewed();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  // Filter chats based on search text
  void _filterChats(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query.toLowerCase();
    });
  }

  // Mark chats as viewed when screen opens
  Future<void> _markChatsAsViewed() async {
    try {
      final chatsRef = _firestore.collection('chats');
      
      // Get chats where current user is a participant
      final snapshot = await chatsRef
          .where('participants', arrayContains: _currentUserId)
          .get();
      
      // Update each chat to mark messages as read
      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'unreadCount.$_currentUserId': 0
        });
      }
    } catch (e) {
      print('Error marking chats as viewed: $e');
    }
  }
  
  // Format timestamp for display
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "";
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
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
      return "Yesterday";
    }
    // Same week
    else if (now.difference(dateTime).inDays < 7) {
      List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[dateTime.weekday - 1];
    }
    // Same year - show month and day
    else if (dateTime.year == now.year) {
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${months[dateTime.month - 1]} ${dateTime.day}";
    } 
    // Different year - show month, day and year
    else {
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}";
    }
  }

  // Get user data for display
  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return {
          'name': userDoc['name'] ?? 'Unknown User',
          'imageUrl': userDoc['profileImage'] ?? '',
        };
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    
    return {
      'name': 'Unknown User',
      'imageUrl': '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterChats,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterChats('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                Expanded(
                  child: _currentUserId == 'guest-user'
                      ? _buildGuestView()
                      : _buildChatList(),
                ),
              ],
            ),
      // FAB to start a new chat
      floatingActionButton: _currentUserId != 'guest-user' 
          ? FloatingActionButton(
              onPressed: () {
                // Show user list to start a new chat
                _showUserListDialog();
              },
              backgroundColor: Color(0xFF1976D2),
              child: Icon(Icons.chat_bubble_outline, color: Colors.white),
            )
          : null,
    );
  }
  
  // Build view for guest users
  Widget _buildGuestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Please log in to see your chats',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
              // Add navigation code here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Login', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
  
  // Build list of chats from Firebase
  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where('participants', arrayContains: _currentUserId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading chats'));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }
        
        final chatDocs = snapshot.data!.docs;
        
        // Filter based on search query if provided
        List<QueryDocumentSnapshot> filteredDocs = chatDocs;
        if (_searchQuery != null && _searchQuery!.isNotEmpty) {
          filteredDocs = chatDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final lastMessage = data['lastMessage']?.toString().toLowerCase() ?? '';
            
            // Check if last message contains search query
            // Can't search by name here because it's not in the chat document
            return lastMessage.contains(_searchQuery!);
          }).toList();
        }
        
        if (filteredDocs.isEmpty && _searchQuery != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No chats match your search',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final chatData = filteredDocs[index].data() as Map<String, dynamic>;
            final chatId = filteredDocs[index].id;
            
            // Get other participant's ID
            final List<String> participants = List<String>.from(chatData['participants'] ?? []);
            final otherParticipantId = participants.firstWhere(
              (id) => id != _currentUserId, 
              orElse: () => 'unknown'
            );
            
            // Determine unread count for current user
            final unreadCounts = chatData['unreadCount'] as Map<String, dynamic>? ?? {};
            final unreadCount = unreadCounts[_currentUserId] as int? ?? 0;
            
            final lastMessage = chatData['lastMessage'] as String? ?? 'No messages yet';
            final lastMessageTimestamp = chatData['lastMessageTimestamp'] as Timestamp? ?? Timestamp.now();
            
            return FutureBuilder<Map<String, dynamic>>(
              future: _getUserData(otherParticipantId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, color: Colors.grey[700]),
                    ),
                    title: Text('Loading...'),
                  );
                }
                
                final userData = userSnapshot.data!;
                
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundImage: userData['imageUrl'].isNotEmpty 
                          ? NetworkImage(userData['imageUrl'])
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: userData['imageUrl'].isEmpty ? Icon(Icons.person, color: Colors.grey[700]) : null,
                      radius: 26,
                    ),
                    title: Text(
                      userData['name'],
                      style: TextStyle(
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTimestamp(lastMessageTimestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: unreadCount > 0 ? Colors.blue : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 5),
                        if (unreadCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    onTap: () async {
                      // Mark chat as read immediately on tap
                      if (unreadCount > 0) {
                        await _firestore.collection('chats').doc(chatId).update({
                          'unreadCount.$_currentUserId': 0
                        });
                      }
                      
                      // Navigate to chat detail page
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ConversationScreen(
                            receiverId: otherParticipantId,
                            receiverName: userData['name'],
                            receiverImage: userData['imageUrl'],
                          )
                        )
                      ).then((_) {
                        // Refresh chats when returning from detail page
                        // (This happens automatically due to StreamBuilder)
                      });
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  
  // Show dialog to select a user to start a chat with
  void _showUserListDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Start New Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1),
              Container(
                height: 300,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading users'));
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No users found'));
                    }
                    
                    // Filter out current user
                    final users = snapshot.data!.docs.where(
                      (doc) => doc.id != _currentUserId
                    ).toList();
                    
                    if (users.isEmpty) {
                      return Center(child: Text('No other users found'));
                    }
                    
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userData = users[index].data() as Map<String, dynamic>;
                        final userId = users[index].id;
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: userData['profileImage'] != null && userData['profileImage'].toString().isNotEmpty
                                ? NetworkImage(userData['profileImage'])
                                : null,
                            backgroundColor: Colors.grey[200],
                            child: userData['profileImage'] == null || userData['profileImage'].toString().isEmpty
                                ? Icon(Icons.person, color: Colors.grey[700])
                                : null,
                          ),
                          title: Text(userData['name'] ?? 'Unknown User'),
                          onTap: () {
                            Navigator.pop(context);
                            _startChat(userId, userData['name'] ?? 'Unknown User', userData['profileImage'] ?? '');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Divider(height: 1),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Start a chat with selected user
  void _startChat(String receiverId, String receiverName, String receiverImage) async {
    try {
      // Check if chat already exists
      final chatId = _currentUserId.hashCode <= receiverId.hashCode
          ? '$_currentUserId-$receiverId'
          : '$receiverId-$_currentUserId';
      
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      // Create chat if it doesn't exist
      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(chatId).set({
          'participants': [_currentUserId, receiverId],
          'lastMessage': '',
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'unreadCount': {
            _currentUserId: 0,
            receiverId: 0,
          }
        });
      }
      
      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationScreen(
            receiverId: receiverId,
            receiverName: receiverName,
            receiverImage: receiverImage,
          ),
        ),
      );
    } catch (e) {
      print('Error starting chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat. Please try again.')),
      );
    }
  }
}

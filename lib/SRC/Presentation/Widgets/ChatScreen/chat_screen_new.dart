import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/ChatScreen/chat_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String _currentUserId = '';
  
  // Chat data
  List<Map<String, dynamic>> _allChats = [];
  List<Map<String, dynamic>> _filteredChats = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Initialize user ID and load chats
  Future<void> _initializeUser() async {
    print('Initializing user...');
    String userId;
    
    // Try to get user ID from different sources
    if (_auth.currentUser != null) {
      userId = _auth.currentUser!.uid;
      print('User ID from Firebase Auth: $userId');
    } else if (Data.app.token != null && Data.app.token!.isNotEmpty) {
      userId = Data.app.token!;
      print('User ID from Data.app.token: $userId');
    } else {
      userId = 'guest-user';
      print('No user ID found, using guest-user');
      
      // Show login prompt for guest users
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to see your chats'),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                // Navigation code would go here
              },
            ),
          ),
        );
      });
    }
    
    setState(() {
      _currentUserId = userId;
    });
    
    if (userId != 'guest-user') {
      await _loadChats();
      await _markChatsAsRead();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load chats from Firestore
  Future<void> _loadChats() async {
    print('======== LOADING CHATS ========');
    print('Loading chats for user ID: $_currentUserId');
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get chats where current user is a participant
      QuerySnapshot chatSnapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .get();
      
      print('Found ${chatSnapshot.docs.length} chats');
      
      if (chatSnapshot.docs.isEmpty) {
        setState(() {
          _allChats = [];
          _filteredChats = [];
          _isLoading = false;
        });
        return;
      }
      
      // Process chat documents to extract necessary information
      List<Map<String, dynamic>> processedChats = [];
      
      for (var chatDoc in chatSnapshot.docs) {
        Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;
        String chatId = chatDoc.id;
        
        try {
          List<String> participants = List<String>.from(chatData['participants'] ?? []);
          
          // Skip chats with insufficient participants
          if (participants.isEmpty || participants.length < 2) {
            print('Skipping chat $chatId: insufficient participants');
            continue;
          }
          
          // Find the other user in the chat
          String otherUserId = participants.firstWhere(
            (id) => id != _currentUserId,
            orElse: () => 'unknown'
          );
          
          if (otherUserId == 'unknown') {
            print('Skipping chat $chatId: could not identify other user');
            continue;
          }
          
          // Get other user's information
          DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(otherUserId)
            .get();
          
          if (!userDoc.exists) {
            print('Skipping chat $chatId: other user does not exist');
            continue;
          }
          
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          
          // Extract last message
          String lastMessage = '';
          Timestamp messageTime = Timestamp.now();
          
          if (chatData.containsKey('lastMessage')) {
            var lastMessageData = chatData['lastMessage'];
            
            if (lastMessageData is String) {
              lastMessage = lastMessageData;
            } else if (lastMessageData is Map) {
              lastMessage = lastMessageData['text']?.toString() ?? 'No messages';
            }
            
            // Get message timestamp
            if (chatData.containsKey('lastMessageTimestamp') && 
                chatData['lastMessageTimestamp'] is Timestamp) {
              messageTime = chatData['lastMessageTimestamp'];
            } else if (lastMessageData is Map && 
                      lastMessageData.containsKey('timestamp')) {
              var timestamp = lastMessageData['timestamp'];
              if (timestamp is Timestamp) {
                messageTime = timestamp;
              }
            }
          }
          
          // Get unread count for current user
          int unreadCount = 0;
          if (chatData.containsKey('unreadCount') && 
              chatData['unreadCount'] is Map) {
            Map<String, dynamic> unreadCounts = 
                chatData['unreadCount'] as Map<String, dynamic>;
            unreadCount = unreadCounts[_currentUserId] ?? 0;
          }
          
          // Create a processed chat entry
          processedChats.add({
            'id': chatId,
            'userId': otherUserId,
            'name': userData['displayName'] ?? userData['name'] ?? 'Unknown User',
            'imageUrl': userData['photoUrl'] ?? userData['profileImage'] ?? '',
            'message': lastMessage,
            'time': _formatTimestamp(messageTime),
            'timestamp': messageTime, // Keep raw timestamp for sorting
            'unread': unreadCount,
          });
        } catch (e) {
          print('Error processing chat $chatId: $e');
        }
      }
      
      // Sort by timestamp (most recent first)
      processedChats.sort((a, b) {
        Timestamp aTime = a['timestamp'] as Timestamp;
        Timestamp bTime = b['timestamp'] as Timestamp;
        return bTime.compareTo(aTime);
      });
      
      setState(() {
        _allChats = processedChats;
        _filteredChats = processedChats;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error loading chats: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show error message with retry option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load conversations. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadChats,
          ),
        ),
      );
    }
  }

  // Filter chats based on search query
  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredChats = List.from(_allChats);
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      
      String lowercaseQuery = query.toLowerCase();
      
      _filteredChats = _allChats.where((chat) {
        String name = (chat['name'] ?? '').toString().toLowerCase();
        String message = (chat['message'] ?? '').toString().toLowerCase();
        
        return name.contains(lowercaseQuery) || 
               message.contains(lowercaseQuery);
      }).toList();
    });
  }

  // Format timestamp for display
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);
    
    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('h:mm a').format(messageTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week - show day name
      return DateFormat('EEEE').format(messageTime);
    } else {
      // Older than a week - show date
      return DateFormat('MMM d').format(messageTime);
    }
  }

  // Mark all chats as read
  Future<void> _markChatsAsRead() async {
    try {
      WriteBatch batch = _firestore.batch();
      bool hasUpdates = false;
      
      // Get all chats with unread messages
      QuerySnapshot chatsWithUnread = await _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .get();
      
      for (var doc in chatsWithUnread.docs) {
        Map<String, dynamic> chatData = doc.data() as Map<String, dynamic>;
        
        if (chatData.containsKey('unreadCount') && 
            chatData['unreadCount'] is Map) {
          Map<String, dynamic> unreadCounts = 
              Map<String, dynamic>.from(chatData['unreadCount']);
          
          if (unreadCounts.containsKey(_currentUserId) && 
              unreadCounts[_currentUserId] > 0) {
            unreadCounts[_currentUserId] = 0;
            batch.update(doc.reference, {'unreadCount': unreadCounts});
            hasUpdates = true;
          }
        }
      }
      
      if (hasUpdates) {
        await batch.commit();
        print('Marked all chats as read for $_currentUserId');
      }
    } catch (e) {
      print('Error marking chats as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChats,
              decoration: InputDecoration(
                hintText: 'Search conversations',
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
          
          // Chat list
          Expanded(
            child: _isLoading 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading your conversations...'),
                      TextButton(
                        onPressed: _loadChats,
                        child: Text('Tap to retry'),
                      ),
                    ],
                  ),
                )
              : _filteredChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          _isSearching ? 'No chats match your search' : 'No conversations yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadChats,
                    child: ListView.builder(
                      itemCount: _filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = _filteredChats[index];
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundImage: chat['imageUrl'].isNotEmpty 
                                  ? NetworkImage(chat['imageUrl']) 
                                  : null,
                              backgroundColor: Colors.grey[200],
                              child: chat['imageUrl'].isEmpty 
                                  ? Icon(Icons.person, color: Colors.grey[700]) 
                                  : null,
                              radius: 26,
                            ),
                            title: Text(
                              chat['name'],
                              style: TextStyle(
                                fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              chat['message'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: chat['unread'] > 0 ? Colors.black87 : Colors.grey[600],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  chat['time'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: chat['unread'] > 0 ? Colors.blue : Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 5),
                                if (chat['unread'] > 0)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      chat['unread'].toString(),
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () async {
                              // Mark this chat as read
                              if (chat['unread'] > 0) {
                                try {
                                  await _firestore
                                    .collection('chats')
                                    .doc(chat['id'])
                                    .update({
                                      'unreadCount.${_currentUserId}': 0
                                    });
                                  
                                  // Update local state
                                  setState(() {
                                    chat['unread'] = 0;
                                  });
                                } catch (e) {
                                  print('Error updating unread count: $e');
                                }
                              }
                              
                              // Navigate to chat detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConversationScreen(
                                    receiverId: chat['userId'],
                                    receiverName: chat['name'],
                                    receiverImage: chat['imageUrl'],
                                  ),
                                ),
                              ).then((_) {
                                // Refresh chat list when returning from conversation
                                _loadChats();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      // No floating action button
    );
  }
}

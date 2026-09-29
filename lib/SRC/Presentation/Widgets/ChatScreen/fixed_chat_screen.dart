import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/ChatScreen/chat_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:intl/intl.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/custom_loader.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String _currentUserId = '';
  String? _errorMessage;
  
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
      
      // Debug info for first chat
      if (chatSnapshot.docs.isNotEmpty) {
        print('First chat data structure:');
        print(chatSnapshot.docs.first.data());
      }

      List<Map<String, dynamic>> formattedChats = [];
      
      // Process each chat document
      for (var chatDoc in chatSnapshot.docs) {
        try {
          Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;
          print('Processing chat ${chatDoc.id}');
          
          // Extract participants
          List<String> participants = List<String>.from(chatData['participants'] ?? []);
          if (participants.length < 2) {
            print('Chat ${chatDoc.id} has less than 2 participants, skipping');
            continue;
          }
          
          // Find the other user ID
          String otherUserId = participants.firstWhere(
            (id) => id != _currentUserId,
            orElse: () => "unknown"
          );
          
          if (otherUserId == "unknown") {
            print('Could not find other user in chat ${chatDoc.id}');
            continue;
          }
          
          // Get other user's details
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(otherUserId).get();
          
          if (!userDoc.exists) {
            print('User document does not exist for ID: $otherUserId');
            continue;
          }
          
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          
          // Extract last message
          String lastMessage = "No messages yet";
          Timestamp lastMessageTimestamp = Timestamp.now();
          
          // Handle different lastMessage formats
          if (chatData.containsKey('lastMessage')) {
            var lastMessageData = chatData['lastMessage'];
            
            if (lastMessageData is String) {
              lastMessage = lastMessageData;
            } else if (lastMessageData is Map) {
              lastMessage = lastMessageData['text']?.toString() ?? "No messages yet";
              
              // Try to get timestamp from the message
              if (lastMessageData.containsKey('timestamp') && 
                  lastMessageData['timestamp'] != null) {
                if (lastMessageData['timestamp'] is Timestamp) {
                  lastMessageTimestamp = lastMessageData['timestamp'];
                }
              }
            }
          }
          
          // Get timestamp from dedicated field if available
          if (chatData.containsKey('lastMessageTimestamp') && 
              chatData['lastMessageTimestamp'] != null &&
              chatData['lastMessageTimestamp'] is Timestamp) {
            lastMessageTimestamp = chatData['lastMessageTimestamp'];
          }
          
          // Get unread count
          int unreadCount = 0;
          if (chatData.containsKey('unreadCount') && 
              chatData['unreadCount'] is Map) {
            Map<String, dynamic> unreadCounts = 
                Map<String, dynamic>.from(chatData['unreadCount']);
            unreadCount = unreadCounts[_currentUserId] ?? 0;
          }
          
          // Create formatted chat object
          formattedChats.add({
            'id': chatDoc.id,
            'userId': otherUserId,
            'name': userData['displayName'] ?? userData['name'] ?? 'Unknown User',
            'imageUrl': userData['photoUrl'] ?? userData['profilePicture'] ?? '',
            'message': lastMessage,
            'time': _formatTimestamp(lastMessageTimestamp),
            'unread': unreadCount,
          });
          
        } catch (e) {
          print('Error processing chat ${chatDoc.id}: $e');
        }
      }
      
      // Sort chats by unread first, then by time
      formattedChats.sort((a, b) {
        if (a['unread'] > 0 && b['unread'] == 0) return -1;
        if (a['unread'] == 0 && b['unread'] > 0) return 1;
        return 0; // Keep original order if unread status is the same
      });
      
      setState(() {
        _allChats = formattedChats;
        _filteredChats = formattedChats;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error loading chats: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load your conversations'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadChats,
          ),
        ),
      );
    }
  }

  // Filter chats based on search text
  void _filterChats(String query) {
    print('Filtering chats with query: "$query"');
    
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        // If query is empty, show all chats
        _filteredChats = List.from(_allChats);
        return;
      }
      
      // Filter chats based on name or last message
      _filteredChats = _allChats.where((chat) {
        final name = (chat['name'] ?? '').toString().toLowerCase();
        final message = (chat['message'] ?? '').toString().toLowerCase();
        final searchLower = query.toLowerCase();
        
        return name.contains(searchLower) || message.contains(searchLower);
      }).toList();
    });
  }

  // Format timestamp into readable string
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageDate = timestamp.toDate();
    final difference = now.difference(messageDate);
    
    if (difference.inDays == 0) {
      // Today: show time
      return DateFormat('h:mm a').format(messageDate);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week: show day name
      return DateFormat('EEEE').format(messageDate);
    } else {
      // Older: show date
      return DateFormat('MMM d').format(messageDate);
    }
  }

  // Mark all chats as read
  Future<void> _markChatsAsRead() async {
    try {
      // Get all chats with unread messages for this user
      QuerySnapshot unreadChats = await _firestore
          .collection('chats')
          .where('participants', arrayContains: _currentUserId)
          .get();
      
      WriteBatch batch = _firestore.batch();
      bool hasUpdates = false;
      
      for (var doc in unreadChats.docs) {
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
        print('Marked chats as read');
      }
    } catch (e) {
      print('Error marking chats as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: LightColorsPalate.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CustomLoader(
                outerSize: 100,
                innerSize: 40,
                opacity: 0.7,
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : _buildChatList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
              });
              // Add your retry logic here
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Column(
        children: [
          // Search bar
          Padding(
          padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChats,
              decoration: InputDecoration(
              hintText: 'Search conversations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
          // Chat list
          Expanded(
          child: _filteredChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                        Text(
                        'Start chatting with other users',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
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
                                fontWeight: chat['unread'] > 0 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat['message'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: chat['unread'] > 0 
                                          ? Colors.black87 
                                          : Colors.grey[600],
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
                                  chat['time'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: chat['unread'] > 0 
                                        ? Colors.blue 
                                        : Colors.grey,
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
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () async {
                              // Mark chat as read
                              if (chat['unread'] > 0) {
                                try {
                                  await _firestore.collection('chats').doc(chat['id']).update({
                                    'unreadCount.${_currentUserId}': 0
                                  });
                                  
                                  setState(() {
                                    chat['unread'] = 0;
                                  });
                                } catch (e) {
                                  print('Error updating unread count: $e');
                                }
                              }
                              
                              // Navigate to chat detail page
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => ConversationScreen(
                                    receiverId: chat['userId'], 
                                    receiverName: chat['name'], 
                                    receiverImage: chat['imageUrl'],
                                  )
                                )
                              ).then((_) {
                                // Refresh chats when returning from conversation
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Data/Models/community_post_model.dart';
import 'package:motorsbay1/SRC/Data/Models/car_recommendation_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/create_post_page.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Recommendation/car_preferences_survey.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/services/community_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Recommendation/services/recommendation_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/user_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/custom_loader.dart';
import 'dart:async';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityService _communityService = CommunityService();
  final ScrollController _scrollController = ScrollController();
  final RecommendationService _recommendationService = RecommendationService();
  int _postsLimit = 10;
  bool _isLoading = false;
  bool _hasSetPreferences = false;
  UserPreference? _userPreferences;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkUserPreferences();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Check if user has set preferences
  Future<void> _checkUserPreferences() async {
    try {
      bool hasPreferences = await _recommendationService.hasSetPreferences();
      setState(() {
        _hasSetPreferences = hasPreferences;
      });

      if (!_hasSetPreferences) {
        // Delayed redirect to give UI time to render
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            _showPreferencesDialog();
          }
        });
      }
    } catch (e) {
      print('Error checking preferences: $e');
    }
  }

  // Load user preferences
  Future<void> _loadUserPreferences() async {
    try {
      final preferences = await _recommendationService.getUserPreferences();
      setState(() {
        _userPreferences = preferences;
      });
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }
  
  // Show dialog to prompt user to set preferences
  void _showPreferencesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Your Preferences'),
          content: Text('Please set your car preferences to see relevant posts and make the most of the community.'),
          actions: [
            TextButton(
              child: Text('Set Preferences'),
              onPressed: () {
                Navigator.pop(context);
                _navigateToPreferenceSettings();
              },
            ),
          ],
        );
      },
    );
  }
  
  // Build a full-screen prompt for users to set preferences
  Widget _buildPreferencesPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Set Your Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'To see relevant content and connect with the community, please set your car preferences first.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToPreferenceSettings,
            icon: Icon(Icons.tune),
            label: Text('Set Preferences Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to preference settings
  void _navigateToPreferenceSettings() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CarPreferencesSurvey(),
      ),
    ).then((_) {
      // Reload preferences and check status when returning from settings
      _checkUserPreferences();
      _loadUserPreferences();
    });
  }

  // Load more posts when scrolling to the bottom
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
          _postsLimit += 10;
        });
        
        // Delay to prevent multiple loads
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    }
  }
    
  // Navigate to user profile page
  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(),
      ),
    );
  }
    
  // Navigate to create post page
  void _navigateToCreatePost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 28, color: Color(0xFF1976D2)),
          onPressed: () {
            _navigateToUserProfile();
          },
          tooltip: 'User Profile',
        ),
        title: Text(
          'Social Community',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFF1976D2)),
            onPressed: _navigateToPreferenceSettings,
            tooltip: 'Preference Settings',
          ),
        ],
      ),
      body: !_hasSetPreferences 
        ? _buildPreferencesPrompt()
        : FutureBuilder<UserPreference>(
            future: _recommendationService.getUserPreferences(),
            builder: (context, prefSnapshot) {
              if (prefSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CustomLoader(
                    outerSize: 100,
                    innerSize: 40,
                    opacity: 0.7,
                  ),
                );
              }
              
              return StreamBuilder<List<CommunityPost>>(
                stream: _communityService.getFilteredPosts(
                  userPreferences: prefSnapshot.data?.toMap() ?? {},
                  limit: _postsLimit
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(
                      child: CustomLoader(
                        outerSize: 100,
                        innerSize: 40,
                        opacity: 0.7,
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  final List<CommunityPost> posts = snapshot.data ?? [];
                  
                  if (posts.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.forum_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No posts yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Be the first to share with the community!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _navigateToCreatePost,
                                icon: Icon(Icons.add),
                                label: Text('Create a post'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: posts.length + 1, // +1 for loading indicator
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        return _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox(height: 80); // Space for FAB
                      }
                      
                      return PostCard(post: posts[index]);
                    },
                  );
                },
              );
            },
          ),
    );
  }
}

// Use existing PostCard implementation

class PostCard extends StatefulWidget {
  final CommunityPost post;
  
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _replyFocusNode = FocusNode();
  bool _isCommenting = false;
  int? _replyingToCommentIndex;
  int _displayedComments = 2;
  bool _showingAllComments = false;
  late CommunityPost _currentPost;
  StreamSubscription<DocumentSnapshot>? _postSubscription;
  
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? Data.app.token;
  
  bool get _isLiked => _currentPost.likes.contains(_currentUserId);

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    // Start listening to changes in the post
    _subscribeToPostUpdates();
  }

  void _subscribeToPostUpdates() {
    if (_currentPost.id != null) {
      _postSubscription = FirebaseFirestore.instance
          .collection('community_posts')
          .doc(_currentPost.id)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            _currentPost = CommunityPost.fromDocument(snapshot);
            // If we're showing all comments, update the displayed count
            if (_showingAllComments) {
              _displayedComments = _currentPost.comments.length;
            }
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _currentPost = widget.post;
      // Renew subscription if post ID changed
      _unsubscribeFromPostUpdates();
      _subscribeToPostUpdates();
    }
  }

  void _unsubscribeFromPostUpdates() {
    _postSubscription?.cancel();
    _postSubscription = null;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    _commentFocusNode.dispose();
    _replyFocusNode.dispose();
    _unsubscribeFromPostUpdates();
    super.dispose();
  }
  
  // Toggle like on a post
  void _toggleLike() async {
    await _communityService.toggleLike(_currentPost.id!);
  }
  
  // Show comments in Instagram-style drawer
  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsDrawer(post: _currentPost),
    );
  }
  
  // Navigate to author's profile
  void _navigateToAuthorProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: _currentPost.userId),
      ),
    );
  }
  
  // Delete the post (only for post author)
  void _confirmDeletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post?'),
        content: Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _communityService.deletePost(_currentPost.id!);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          ListTile(
            leading: GestureDetector(
              onTap: () => _navigateToAuthorProfile(),
              child: CircleAvatar(
                backgroundImage: _currentPost.userPhotoUrl.isNotEmpty
                    ? NetworkImage(_currentPost.userPhotoUrl)
                    : null,
                onBackgroundImageError: _currentPost.userPhotoUrl.isNotEmpty
                    ? (exception, stackTrace) {
                        print('Error loading post author image: $exception');
                      } 
                    : null,
                child: _currentPost.userPhotoUrl.isEmpty
                    ? Text(_currentPost.userName[0].toUpperCase())
                    : null,
              ),
            ),
            title: GestureDetector(
              onTap: () => _navigateToAuthorProfile(),
              child: Text(
                _currentPost.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              timeago.format(_currentPost.timestamp),
              style: TextStyle(fontSize: 12),
            ),
            trailing: _currentPost.userId == _currentUserId
                ? IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete Post'),
                              onTap: () {
                                Navigator.pop(context);
                                _confirmDeletePost();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : null,
          ),
          
          // Post description
          if (_currentPost.description.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(_currentPost.description),
            ),
          
          // Post images
          if (_currentPost.imageUrls.isNotEmpty)
            Container(
              height: _currentPost.imageUrls.length > 1 ? 200 : null,
              child: _currentPost.imageUrls.length == 1
                  ? CachedNetworkImage(
                      imageUrl: _currentPost.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _currentPost.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width - 24,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _currentPost.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          
          // Like and comment counts
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: Colors.blue,
                ),
                SizedBox(width: 4),
                Text(
                  '${_currentPost.likes.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                if (_currentPost.comments.isNotEmpty)
                  Text(
                    '${_currentPost.comments.length} ${_currentPost.comments.length == 1 ? 'comment' : 'comments'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          
          // Divider
          Divider(height: 1),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _toggleLike,
                icon: Icon(
                  _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: _isLiked ? Colors.blue : Colors.grey,
                ),
                label: Text(
                  'Like',
                  style: TextStyle(
                    color: _isLiked ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _showComments,
                icon: Icon(Icons.comment_outlined, color: Colors.grey),
                label: Text('Comment', style: TextStyle(color: Colors.grey)),
              ),
              TextButton.icon(
                onPressed: _sharePost,
                icon: Icon(Icons.share_outlined, color: Colors.grey),
                label: Text('Share', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Share the post
  void _sharePost() {
    // Create a share message with the post details
    final String shareMessage = 
        '${_currentPost.userName} shared a post on MotorsBay:\n\n'
        '${_currentPost.description}\n\n'
        'Open MotorsBay app to see more!';
    Share.share(shareMessage);
  }
}

// Instagram-style comments drawer
class CommentsDrawer extends StatefulWidget {
  final CommunityPost post;

  const CommentsDrawer({Key? key, required this.post}) : super(key: key);

  @override
  _CommentsDrawerState createState() => _CommentsDrawerState();
}

class _CommentsDrawerState extends State<CommentsDrawer> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  StreamSubscription<DocumentSnapshot>? _postSubscription;
  late CommunityPost _currentPost;
  int? _replyingToIndex;
  
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? Data.app.token;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _subscribeToPostUpdates();
    
    // Focus the comment field automatically
    Future.delayed(Duration(milliseconds: 300), () {
      _commentFocusNode.requestFocus();
    });
  }
  
  void _subscribeToPostUpdates() {
    if (_currentPost.id != null) {
      _postSubscription = FirebaseFirestore.instance
          .collection('community_posts')
          .doc(_currentPost.id)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            _currentPost = CommunityPost.fromDocument(snapshot);
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _postSubscription?.cancel();
    super.dispose();
  }
  
  // Start reply mode
  void _startReply(Comment comment, int index) {
    debugPrint('=== STARTING REPLY MODE ===');
    debugPrint('💬 Comment index: $index');
    debugPrint('👤 Comment author: ${comment.userId}');
    
    setState(() {
      _replyingToIndex = index;
      _commentController.clear();
    });
    // Focus the input field and show keyboard
    _commentFocusNode.requestFocus();
    debugPrint('✅ Reply mode started, keyboard focused');
  }

  // Cancel reply mode
  void _cancelReply() {
    debugPrint('=== CANCELLING REPLY MODE ===');
    setState(() {
      _replyingToIndex = null;
      _commentController.clear();
    });
    debugPrint('✅ Reply mode cancelled');
  }

  // Add a new comment or reply
  Future<void> _addComment() async {
    final String text = _commentController.text.trim();
    
    debugPrint('=== ADDING COMMENT/REPLY ===');
    debugPrint('📝 Text: $text');
    debugPrint('💬 Is reply: ${_replyingToIndex != null}');
    if (_replyingToIndex != null) {
      debugPrint('👤 Replying to comment at index: $_replyingToIndex');
    }
    
    if (text.isNotEmpty) {
      try {
        if (_replyingToIndex != null) {
          // Add reply
          debugPrint('📤 Sending reply to Firebase...');
          await _communityService.addReply(
            _currentPost.id!,
            _replyingToIndex.toString(),
            text,
          );
          debugPrint('✅ Reply sent successfully');
          
          // Clear reply mode and input field
          setState(() {
            _replyingToIndex = null;
        _commentController.clear();
          });
          debugPrint('🧹 Reply mode cleared');
        } else {
          // Add comment
          debugPrint('📤 Sending comment to Firebase...');
          await _communityService.addComment(_currentPost.id!, text);
          debugPrint('✅ Comment sent successfully');
          
          // Clear input field
          _commentController.clear();
          debugPrint('🧹 Comment field cleared');
        }
        
        // Show success message
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_replyingToIndex != null ? 'Reply added successfully' : 'Comment added successfully'),
              duration: Duration(seconds: 1)
            ),
        );
          debugPrint('📱 Success message shown');
        }
      } catch (e) {
        debugPrint('❌ Error: $e');
        // Show error message
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
          debugPrint('📱 Error message shown');
        }
      }
    } else {
      debugPrint('⚠️ Empty text, not sending');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Center(
              child: Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Comments List
          Expanded(
            child: _currentPost.comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet.\nBe the first to comment!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _currentPost.comments.length,
                    padding: EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      // Display in reverse chronological order (newest first)
                      int reverseIndex = _currentPost.comments.length - 1 - index;
                      return _buildCommentItem(_currentPost.comments[reverseIndex], reverseIndex);
                    },
                  ),
          ),
          
          // Reply indicator (if replying)
          if (_replyingToIndex != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Text(
                    'Replying to ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    _currentPost.comments[_replyingToIndex!].userId == _currentPost.userId 
                        ? _currentPost.userName 
                        : 'User ${_currentPost.comments[_replyingToIndex!].userId.substring(0, 4)}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: _cancelReply,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          
          // Comment Input Field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 16,
                  backgroundImage: _currentUserId == _currentPost.userId && _currentPost.userPhotoUrl.isNotEmpty
                      ? NetworkImage(_currentPost.userPhotoUrl)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: _currentUserId != _currentPost.userId || _currentPost.userPhotoUrl.isEmpty
                      ? Icon(Icons.person, size: 16, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 12),
                
                // Comment TextField
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: _replyingToIndex != null ? 'Write a reply...' : 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: TextStyle(fontSize: 14),
                    maxLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                SizedBox(width: 8),
                
                // Send Button
                IconButton(
                  onPressed: _addComment,
                  icon: Icon(Icons.send, color: Color(0xFF1976D2)),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Bottom padding for keyboard
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
  
  Widget _buildCommentItem(Comment comment, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          FutureBuilder<Map<String, String>>(
            future: _communityService.getUserProfileData(comment.userId),
            builder: (context, snapshot) {
              final hasProfilePic = snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null &&
                  snapshot.data!['photoUrl'] != null &&
                  snapshot.data!['photoUrl']!.isNotEmpty;
                  
              // If comment is from post author, use post's user photo
              if (comment.userId == _currentPost.userId && _currentPost.userPhotoUrl.isNotEmpty) {
                return CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(_currentPost.userPhotoUrl),
                  backgroundColor: Colors.grey[300],
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading author profile pic: $exception');
                  },
                );
              }
                  
              return CircleAvatar(
                radius: 16,
                backgroundImage: hasProfilePic ? NetworkImage(snapshot.data!['photoUrl']!) : null,
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: hasProfilePic ? (exception, stackTrace) {
                  print('Error loading profile pic: $exception');
                } : null,
                child: !hasProfilePic
                    ? Text(comment.userId.substring(0, 1).toUpperCase())
                    : null,
              );
            },
          ),
          SizedBox(width: 12),
          
          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Username
                    FutureBuilder<Map<String, String>>(
                      future: _communityService.getUserProfileData(comment.userId),
                      builder: (context, snapshot) {
                        final displayName = comment.userId == _currentPost.userId 
                            ? _currentPost.userName 
                            : (snapshot.connectionState == ConnectionState.done && snapshot.data != null)
                                ? snapshot.data!['username']!
                                : 'User ${comment.userId.substring(0, 4)}';
                        
                        return Text(
                          displayName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    
                    // Comment Time
                    Text(
                      timeago.format(comment.timestamp),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                
                // Comment Text
                Text(
                  comment.text,
                  style: TextStyle(fontSize: 14),
                ),
                
                // Reply Button
                TextButton(
                  onPressed: () => _startReply(comment, index),
                  child: Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                
                // Replies (if any)
                if (comment.replies.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: comment.replies.map((reply) => _buildReplyItem(reply)).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReplyItem(Reply reply) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture (smaller for replies)
          FutureBuilder<Map<String, String>>(
            future: _communityService.getUserProfileData(reply.userId),
            builder: (context, snapshot) {
              final hasProfilePic = snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null &&
                  snapshot.data!['photoUrl'] != null &&
                  snapshot.data!['photoUrl']!.isNotEmpty;
                  
              return CircleAvatar(
                radius: 12,
                backgroundImage: hasProfilePic ? NetworkImage(snapshot.data!['photoUrl']!) : null,
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: hasProfilePic ? (exception, stackTrace) {
                  print('Error loading profile pic: $exception');
                } : null,
                child: !hasProfilePic
                    ? Text(reply.userId.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 10))
                    : null,
              );
            },
          ),
          SizedBox(width: 8),
          
          // Reply Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Username
                    FutureBuilder<Map<String, String>>(
                      future: _communityService.getUserProfileData(reply.userId),
                      builder: (context, snapshot) {
                        final displayName = (snapshot.connectionState == ConnectionState.done && snapshot.data != null)
                                ? snapshot.data!['username']!
                                : 'User ${reply.userId.substring(0, 4)}';
                        
                        return Text(
                          displayName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    
                    // Reply Time
                    Text(
                      timeago.format(reply.timestamp),
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                
                // Reply Text
                Text(
                  reply.text,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
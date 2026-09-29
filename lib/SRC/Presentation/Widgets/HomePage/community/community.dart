import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Data/Models/community_post_model.dart';
import 'package:motorsbay1/SRC/Data/Models/car_recommendation_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/community/create_post_page.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Recommendation/car_preferences_survey.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/services/community_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Recommendation/services/recommendation_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/community/user_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/custom_loader.dart';
import 'dart:async';

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

  // Add a new comment
  void _addComment() async {
    final String comment = _commentController.text.trim();
    
    if (comment.isNotEmpty) {
      try {
        await _communityService.addComment(_currentPost.id!, comment);
        _commentController.clear();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment added successfully'), duration: Duration(seconds: 1)),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding comment: $e')),
        );
      }
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
                      return _buildCommentItem(_currentPost.comments[reverseIndex]);
                    },
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
                      hintText: 'Add a comment...',
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

  Widget _buildCommentItem(Comment comment) {
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
                  onPressed: () {
                    _showReplyDialog(context, _currentPost.id!, comment);
                  },
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

  // Add reply dialog
  void _showReplyDialog(BuildContext context, String postId, Comment comment) {
    TextEditingController _replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Reply'),
        content: TextField(
          controller: _replyController,
          decoration: InputDecoration(
            hintText: 'Write your reply...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_replyController.text.trim().isNotEmpty) {
                try {
                  await _communityService.addReply(
                    postId,
                    comment.id,
                    _replyController.text.trim(),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding reply: $e')),
                  );
                }
              }
            },
            child: Text('Post'),
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
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Data/Models/community_post_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/services/community_service.dart';

class UserProfilePage extends StatefulWidget {
  final String? userId;
  
  const UserProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _currentUserId;
  String? _profileUserId;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isFollowing = false;
  List<String> _followers = [];
  List<CommunityPost> _userPosts = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? Data.app.token;
    _profileUserId = widget.userId ?? _currentUserId;
    _loadUserData();
    _loadUserPosts();
    _checkFollowStatus();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_profileUserId).get();
      
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadUserPosts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Debugging
      print("Attempting to load posts for user ID: $_profileUserId");
      
      if (_profileUserId == null || _profileUserId!.isEmpty) {
        print("No valid profile user ID to load posts");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Use the community service instead of direct Firestore access
      Stream<List<CommunityPost>> postsStream = _communityService.getUserPosts(_profileUserId!);
      
      postsStream.listen((posts) {
        if (mounted) {
          print("Loaded ${posts.length} posts for user");
          setState(() {
            _userPosts = posts;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        print("Error in post stream: $error");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });

      // Also try direct Firestore access as fallback
      QuerySnapshot postsSnapshot = await _firestore
          .collection('community_posts')
          .where('userId', isEqualTo: _profileUserId)
          .orderBy('timestamp', descending: true)
          .get();
      
      if (mounted && _userPosts.isEmpty) {
        print("Loaded ${postsSnapshot.docs.length} posts using direct Firestore query");
        setState(() {
          _userPosts = postsSnapshot.docs
              .map((doc) {
                try {
                  return CommunityPost.fromDocument(doc);
                } catch (e) {
                  print("Error parsing post document: $e");
                  return null;
                }
              })
              .where((post) => post != null)
              .cast<CommunityPost>()
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _checkFollowStatus() async {
    if (_currentUserId == _profileUserId) return; // No need to check if viewing own profile
    
    try {
      DocumentSnapshot followDoc = await _firestore
          .collection('users')
          .doc(_profileUserId)
          .collection('followers')
          .doc(_currentUserId)
          .get();
          
      setState(() {
        _isFollowing = followDoc.exists;
      });
      
      // Load followers list
      QuerySnapshot followersSnapshot = await _firestore
          .collection('users')
          .doc(_profileUserId)
          .collection('followers')
          .get();
          
      setState(() {
        _followers = followersSnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }
  
  Future<void> _toggleFollow() async {
    if (_currentUserId == null || _profileUserId == null) return;
    
    try {
      DocumentReference followerRef = _firestore
          .collection('users')
          .doc(_profileUserId)
          .collection('followers')
          .doc(_currentUserId);
          
      DocumentReference followingRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('following')
          .doc(_profileUserId);
      
      if (_isFollowing) {
        // Unfollow
        await followerRef.delete();
        await followingRef.delete();
      } else {
        // Follow
        await followerRef.set({
          'timestamp': FieldValue.serverTimestamp(),
        });
        await followingRef.set({
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      
      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          _followers.add(_currentUserId!);
        } else {
          _followers.remove(_currentUserId);
        }
      });
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading ? 'Profile' : (_userData?['displayName'] ?? 'User'),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF1976D2),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Posts'),
            Tab(text: 'Likes'),
            Tab(text: 'Followers'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile header
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _userData?['photoUrl'] != null && _userData!['photoUrl'].toString().isNotEmpty
                          ? NetworkImage(_userData!['photoUrl'])
                          : null,
                        backgroundColor: Colors.grey[200],
                        child: _userData?['photoUrl'] == null || _userData!['photoUrl'].toString().isEmpty
                          ? Icon(Icons.person, size: 40, color: Colors.grey[700])
                          : null,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userData?['displayName'] ?? 'User',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${_userPosts.length} posts • ${_followers.length} followers',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentUserId != _profileUserId)
                        ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing ? Colors.grey[300] : Color(0xFF1976D2),
                            foregroundColor: _isFollowing ? Colors.black : Colors.white,
                          ),
                          child: Text(_isFollowing ? 'Following' : 'Follow'),
                        ),
                    ],
                  ),
                ),
                Divider(),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Posts tab
                      _buildPostsTab(),
                      
                      // Likes tab
                      _buildLikesTab(),
                      
                      // Followers tab
                      _buildFollowersTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildPostsTab() {
    if (_userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        CommunityPost post = _userPosts[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  post.description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              if (post.imageUrls.isNotEmpty)
                Container(
                  height: 200,
                  child: PageView.builder(
                    itemCount: post.imageUrls.length,
                    itemBuilder: (context, imageIndex) {
                      return Image.network(
                        post.imageUrls[imageIndex],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 8),
                    Text('${post.likes.length} likes'),
                    SizedBox(width: 16),
                    Icon(Icons.comment, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('${post.comments.length} comments'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLikesTab() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('community_posts')
          .where('likes', arrayContains: _profileUserId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No likes yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        List<CommunityPost> likedPosts = snapshot.data!.docs
            .map((doc) => CommunityPost.fromDocument(doc))
            .toList();
            
        return ListView.builder(
          itemCount: likedPosts.length,
          itemBuilder: (context, index) {
            CommunityPost post = likedPosts[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: post.userPhotoUrl.isNotEmpty
                      ? NetworkImage(post.userPhotoUrl)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: post.userPhotoUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[700])
                      : null,
                ),
                title: Text(post.userName),
                subtitle: Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(userId: post.userId),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFollowersTab() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('users')
          .doc(_profileUserId)
          .collection('followers')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No followers yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        List<String> followerIds = snapshot.data!.docs.map((doc) => doc.id).toList();
        
        return ListView.builder(
          itemCount: followerIds.length,
          itemBuilder: (context, index) {
            String followerId = followerIds[index];
            
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(followerId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.grey[200]),
                    title: Text('Loading...'),
                  );
                }
                
                Map<String, dynamic>? userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userData?['photoUrl'] != null && userData!['photoUrl'].toString().isNotEmpty
                        ? NetworkImage(userData['photoUrl'])
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: userData?['photoUrl'] == null || userData!['photoUrl'].toString().isEmpty
                        ? Icon(Icons.person, color: Colors.grey[700])
                        : null,
                  ),
                  title: Text(userData?['displayName'] ?? 'User'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(userId: followerId),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
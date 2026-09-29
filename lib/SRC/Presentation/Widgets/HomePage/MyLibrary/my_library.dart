import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motorsbay1/SRC/Data/Models/community_post_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/car_detail_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/carBrandList.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/services/community_service.dart';
import 'package:motorsbay1/exports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;


class MyLibrary extends StatefulWidget {
  const MyLibrary({super.key});

  @override
  State<MyLibrary> createState() => _MyLibraryState();
}

class _MyLibraryState extends State<MyLibrary> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final CommunityService _communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getUserAds(String listingType) {
    return FirebaseFirestore.instance
        .collection("cars")
        .doc(userId)
        .collection("user_cars")
        .where("listingType", isEqualTo: listingType)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Library"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Cars"),
            Tab(text: "Posts"),
            // Tab(text: "Bikes"),
            // Tab(text: "AutoParts"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildAdList("car"),
          buildUserPosts(),
          // buildAdList("bike"),
          // buildAdList("autoParts"),
        ],
      ),
    );
  }

  Widget buildUserPosts() {
    return StreamBuilder<List<CommunityPost>>(
      stream: _communityService.getUserPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading posts: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: 60, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  "You haven't created any posts yet",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create_post');
                  },
                  icon: Icon(Icons.add),
                  label: Text("Create a post"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  _showPostDetailDialog(context, post);
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeago.format(post.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                                label: Text('Edit', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  minimumSize: Size(0, 0),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreatePostPage(
                                        isEditing: true,
                                        post: post,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              TextButton.icon(
                                icon: Icon(Icons.delete, size: 16, color: Colors.red),
                                label: Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  minimumSize: Size(0, 0),
                                ),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Post'),
                                      content: Text('Are you sure you want to delete this post?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ) ?? false;
                                  
                                  if (confirm) {
                                    try {
                                      await _communityService.deletePost(post.id!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Post deleted successfully')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error deleting post: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          post.description.length > 50 
                              ? "${post.description.substring(0, 50)}..." 
                              : post.description,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.favorite, Colors.red, post.likes.length.toString(), "Likes"),
                          _buildStatItem(Icons.comment, Colors.blue, post.comments.length.toString(), "Comments"),
                          _buildStatItem(Icons.share, Colors.green, "0", "Shares"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildStatItem(IconData icon, Color color, String count, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  void _showPostDetailDialog(BuildContext context, CommunityPost post) {
    TextEditingController _commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.userPhotoUrl.isNotEmpty
                          ? NetworkImage(post.userPhotoUrl)
                          : null,
                      child: post.userPhotoUrl.isEmpty
                          ? Icon(Icons.person)
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            timeago.format(post.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              Divider(height: 1),
              
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        post.description,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    
                    if (post.imageUrls.isNotEmpty)
                      Container(
                        height: 220,
                        child: PageView.builder(
                          itemCount: post.imageUrls.length,
                          itemBuilder: (context, imageIndex) {
                            return CachedNetworkImage(
                              imageUrl: post.imageUrls[imageIndex],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      ),
                      
                    if (post.brand != null || post.carStyle != null || post.fuelType != null)
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.brand != null) 
                                _buildInfoRow("Brand", post.brand!),
                              if (post.carStyle != null) 
                                _buildInfoRow("Style", post.carStyle!),
                              if (post.fuelType != null) 
                                _buildInfoRow("Fuel", post.fuelType!),
                            ],
                          ),
                        ),
                      ),
                      
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                await _communityService.toggleLike(post.id!);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.favorite,
                              color: post.likes.contains(userId) 
                                  ? Colors.red 
                                  : Colors.grey,
                              size: 20,
                            ),
                            label: Text(
                              '${post.likes.length}',
                              style: TextStyle(
                                color: Colors.grey[800],
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size(0, 0),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.comment, color: Colors.blue, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '${post.comments.length}',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              // Share functionality
                            },
                            icon: Icon(Icons.share, color: Colors.green, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    
                    Divider(),
                    
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comments',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          if (post.comments.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'No comments yet. Be the first to comment!',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...post.comments.map((comment) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      comment.text,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          timeago.format(comment.timestamp),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            _showReplyDialog(context, post.id!, comment);
                                          },
                                          child: Text(
                                            'Reply',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (comment.replies.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: comment.replies.map((reply) => 
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              reply.text,
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              timeago.format(reply.timestamp),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 11,
                                              ),
                                            ),
                                          )
                                        ).toList(),
                                      ),
                                    ),
                                    
                                  Divider(),
                                ],
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                      onPressed: () async {
                        if (_commentController.text.trim().isNotEmpty) {
                          try {
                            await _communityService.addComment(
                              post.id!,
                              _commentController.text.trim(),
                            );
                            _commentController.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error adding comment: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
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
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAdList(String listingType) {
    return StreamBuilder(
      stream: getUserAds(listingType),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching data"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $listingType available"));
        }

        var ads = snapshot.data!.docs;

        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: ads.length,
          itemBuilder: (context, index) {
            var ad = ads[index].data() as Map<String, dynamic>;            final carId = ads[index].id;
              return GestureDetector(
              onTap: () {
                // Navigate to detailed view with edit/delete options
                Navigator.push(
                  context,
                  MaterialPageRoute(                    builder: (context) => CarDetailScreen(
                      carData: ad,
                      carId: carId,
                    ),
                  ),
                );
              },              child: CarItem(
                carName: ad["title"] ?? "No Title",
                price: ad["price"] ?? "0",
                kmDriven: ad["kmDriven"] ?? "0",
                fuelType: ad["fuelType"] ?? "petroleum",
                color: ad["color"] ?? "",
                modelYear: ad["modelYear"] ?? "",
                city: ad["city"] ?? "Islamabad",
                registerIn: ad["registerIn"] ?? "Islamabad",
                imagePath: ad["imageUrls"] != null && (ad["imageUrls"] as List).isNotEmpty ? ad["imageUrls"][0] : "",
              ),
            );;
          },
        ).padHorizontal(10);
      },
    );
  }
}

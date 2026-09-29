import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Data/Models/community_post_model.dart';
import 'package:uuid/uuid.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  final CollectionReference _postsCollection = 
      FirebaseFirestore.instance.collection('community_posts');

  // Get stream of all posts with pagination
  Stream<List<CommunityPost>> getPosts({int limit = 15}) {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommunityPost.fromDocument(doc))
              .toList();
        });
  }

  // Get filtered posts based on user preferences
  Stream<List<CommunityPost>> getFilteredPosts({
    required Map<String, dynamic> userPreferences,
    int limit = 15,
  }) async* {
    // Get all posts first
    final postsStream = _postsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit * 3) // Fetch more to account for filtering
        .snapshots();
        
    await for (QuerySnapshot snapshot in postsStream) {
      List<CommunityPost> allPosts = snapshot.docs
          .map((doc) => CommunityPost.fromDocument(doc))
          .toList();
          
      // Filter posts based on preferences
      List<CommunityPost> filteredPosts = _filterPostsByPreferences(allPosts, userPreferences);
      
      // If filtered list is too small, return all posts
      if (filteredPosts.length < 5) {
        yield allPosts.take(limit).toList();
      } else {
        yield filteredPosts.take(limit).toList();
      }
    }
  }
  
  // Helper method to filter posts based on user preferences
  List<CommunityPost> _filterPostsByPreferences(
    List<CommunityPost> posts,
    Map<String, dynamic> preferences,
  ) {
    // Extract user preferences
    List<String> preferredBrands = List<String>.from(preferences['preferredBrands'] ?? []);
    String preferredFuelType = preferences['preferredFuelType'] ?? '';
    String preferredCity = preferences['preferredCity'] ?? '';
    List<String> preferredStyles = List<String>.from(preferences['preferredStyles'] ?? []);
    bool preferHas3DModel = preferences['has3DModel'] ?? false;
    
    // Sort and filter posts
    List<CommunityPost> result = List.from(posts);
    
    // Apply filtering - prioritize posts that match user preferences
    result.sort((a, b) {
      int scoreA = _calculatePostRelevanceScore(a, preferredBrands, preferredFuelType, preferredCity, preferredStyles, preferHas3DModel);
      int scoreB = _calculatePostRelevanceScore(b, preferredBrands, preferredFuelType, preferredCity, preferredStyles, preferHas3DModel);
      
      // Higher score first, but if scores are equal, sort by timestamp
      if (scoreB != scoreA) {
        return scoreB.compareTo(scoreA);
      } else {
        return b.timestamp.compareTo(a.timestamp);
      }
    });
    
    return result;
  }
  
  // Calculate relevance score for a post based on user preferences
  int _calculatePostRelevanceScore(
    CommunityPost post, 
    List<String> preferredBrands, 
    String preferredFuelType,
    String preferredCity,
    List<String> preferredStyles,
    bool preferHas3DModel
  ) {
    int score = 0;
    
    // Brand match
    if (post.brand != null && preferredBrands.contains(post.brand)) {
      score += 3;
    }
    
    // Fuel type match
    if (post.fuelType != null && post.fuelType == preferredFuelType) {
      score += 2;
    }
    
    // City match
    if (post.city != null && post.city == preferredCity) {
      score += 2;
    }
    
    // Car style match
    if (post.carStyle != null && preferredStyles.contains(post.carStyle)) {
      score += 3;
    }
    
    // 3D model availability match
    if (preferHas3DModel && post.has3DModel) {
      score += 2;
    }
    
    return score;
  }

  // Get a specific post by ID
  Future<CommunityPost?> getPostById(String postId) async {
    DocumentSnapshot doc = await _postsCollection.doc(postId).get();
    if (doc.exists) {
      return CommunityPost.fromDocument(doc);
    }
    return null;
  }

  // Get posts created by a specific user
  Stream<List<CommunityPost>> getUserPosts(String userId, {int limit = 15}) {
    // Query posts by user ID without using orderBy to avoid index requirements
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          var posts = snapshot.docs
              .map((doc) => CommunityPost.fromDocument(doc))
              .toList();
          
          // Sort client-side instead of using orderBy in the query
          posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          // Apply limit after sorting
          if (posts.length > limit) {
            return posts.sublist(0, limit);
          }
          return posts;
        });
  }

  // Create a new post
  Future<String?> createPost({
    required String description,
    required List<XFile> images,
    String? brand,
    String? fuelType,
    String? city,
    String? carStyle,
    bool? has3DModel,
  }) async {
    try {
      debugPrint('=== COMMUNITY SERVICE: POST CREATION STARTED ===');
      
      // Get current user
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? Data.app.token;
      
      debugPrint('👤 Current user ID: $userId');
      
      if (userId == null) {
        debugPrint('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      // Get user information from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      String userName = 'Anonymous User';
      String userPhotoUrl = '';

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Try to get username from different possible fields
        if (userData['displayName'] != null && userData['displayName'].toString().isNotEmpty) {
          userName = userData['displayName'];
        } else if (userData['name'] != null && userData['name'].toString().isNotEmpty) {
          userName = userData['name'];
        } else if (userData['userName'] != null && userData['userName'].toString().isNotEmpty) {
          userName = userData['userName'];
        }
        
        // Try to get photo URL from different possible fields
        if (userData['photoUrl'] != null && userData['photoUrl'].toString().isNotEmpty) {
          userPhotoUrl = userData['photoUrl'];
        } else if (userData['profilePic'] != null && userData['profilePic'].toString().isNotEmpty) {
          userPhotoUrl = userData['profilePic'];
        } else if (userData['profileImage'] != null && userData['profileImage'].toString().isNotEmpty) {
          userPhotoUrl = userData['profileImage'];
        }
      }

      debugPrint('👤 User info - Name: $userName, Photo: $userPhotoUrl');

      // Upload images and get their URLs
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        debugPrint('📸 Starting image upload for ${images.length} images');
        imageUrls = await _uploadImages(images);
        debugPrint('✅ Image upload completed. URLs: $imageUrls');
      }

      // Create post document
      CommunityPost post = CommunityPost(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        description: description,
        imageUrls: imageUrls,
        timestamp: DateTime.now(),
        likes: [], // Initialize empty likes list
        comments: [], // Initialize empty comments list
        brand: brand,
        fuelType: fuelType,
        city: city,
        carStyle: carStyle,
        has3DModel: has3DModel ?? false,
      );

      debugPrint('📝 Creating post in Firestore...');
      // Add to Firestore
      DocumentReference docRef = await _postsCollection.add(post.toMap());
      debugPrint('✅ Post created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating post: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  // Upload multiple images and return URLs
  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> imageUrls = [];
    
    for (var image in images) {
      try {
        debugPrint('📤 Uploading image: ${image.path}');
        final String fileName = '${Uuid().v4()}.jpg';
        final Reference storageRef = _storage.ref().child('community_images/$fileName');
        
        // Create metadata with content type
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': image.path},
        );
        
        debugPrint('📤 Starting upload to Firebase Storage...');
        // Create upload task with metadata
        UploadTask uploadTask = storageRef.putFile(
          File(image.path),
          metadata,
        );
        
        // Add progress listener
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          debugPrint('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
        });
        
        debugPrint('⏳ Waiting for upload to complete...');
        // Wait for upload with timeout
        TaskSnapshot taskSnapshot = await uploadTask.timeout(
          Duration(seconds: 30),
          onTimeout: () {
            debugPrint('❌ Upload timed out after 30 seconds');
            throw TimeoutException('Image upload timed out');
          },
        );
        
        debugPrint('🔗 Getting download URL...');
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        debugPrint('✅ Image uploaded successfully. URL: $downloadUrl');
        
        imageUrls.add(downloadUrl);
      } catch (e, stackTrace) {
        debugPrint('❌ Error uploading image: $e');
        debugPrint('Stack trace: $stackTrace');
        // If one image fails, we should probably fail the entire post creation
        rethrow;
      }
    }
    
    return imageUrls;
  }

  // Like or unlike a post
  Future<void> toggleLike(String postId) async {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? Data.app.token;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    DocumentReference postRef = _postsCollection.doc(postId);
    DocumentSnapshot doc = await postRef.get();
    
    if (!doc.exists) {
      throw Exception('Post does not exist');
    }
    
    final postData = doc.data() as Map<String, dynamic>;
    List<String> likes = List<String>.from(postData['likes'] ?? []);
    
    if (likes.contains(userId)) {
      // Unlike
      likes.remove(userId);
    } else {
      // Like
      likes.add(userId);
    }
    
    await postRef.update({'likes': likes});
  }

  // Add comment to a post
  Future<void> addComment(String postId, String commentText) async {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? Data.app.token;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    DocumentReference postRef = _postsCollection.doc(postId);
    DocumentSnapshot doc = await postRef.get();
    
    if (!doc.exists) {
      throw Exception('Post does not exist');
    }
    
    final postData = doc.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> comments = 
        List<Map<String, dynamic>>.from(postData['comments'] ?? []);
    
    // Create a map with a regular DateTime instead of FieldValue.serverTimestamp()
    Map<String, dynamic> newComment = {
      'userId': userId,
      'text': commentText,
      'timestamp': Timestamp.now(), // Use Timestamp.now() instead of FieldValue.serverTimestamp()
      'replies': [],
    };
    
    comments.add(newComment);
    
    await postRef.update({'comments': comments});
  }

  // Add reply to a comment
  Future<void> addReply(String postId, String commentId, String replyText) async {
    debugPrint('=== COMMUNITY SERVICE: REPLY CREATION STARTED ===');
    debugPrint('📝 Post ID: $postId');
    debugPrint('💬 Comment ID: $commentId');
    debugPrint('✍️ Reply text: $replyText');

    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? Data.app.token;
    
    debugPrint('👤 Current user ID: $userId');
    
    if (userId == null) {
      debugPrint('❌ User not authenticated');
      throw Exception('User not authenticated');
    }

    DocumentReference postRef = _postsCollection.doc(postId);
    DocumentSnapshot doc = await postRef.get();
    
    if (!doc.exists) {
      debugPrint('❌ Post does not exist');
      throw Exception('Post does not exist');
    }
    
    final postData = doc.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> comments = 
        List<Map<String, dynamic>>.from(postData['comments'] ?? []);
    
    debugPrint('📊 Found ${comments.length} comments in post');
    
    // Find the comment by its index in the array
    int commentIndex = int.tryParse(commentId) ?? -1;
    if (commentIndex < 0 || commentIndex >= comments.length) {
      debugPrint('❌ Invalid comment index: $commentIndex');
      throw Exception('Comment does not exist');
    }
    
    debugPrint('✅ Found comment at index: $commentIndex');
    
    // Initialize replies list if it doesn't exist
    if (comments[commentIndex]['replies'] == null) {
      debugPrint('📝 Initializing empty replies list for comment');
      comments[commentIndex]['replies'] = [];
    }
    
    List<Map<String, dynamic>> replies = 
        List<Map<String, dynamic>>.from(comments[commentIndex]['replies'] ?? []);
    
    debugPrint('📊 Current replies count: ${replies.length}');
    
    // Create new reply
    Map<String, dynamic> newReply = {
      'userId': userId,
      'text': replyText,
      'timestamp': Timestamp.now(),
    };
    
    replies.add(newReply);
    comments[commentIndex]['replies'] = replies;
    
    debugPrint('📝 Adding new reply to comment');
    
    // Update the post document
    await postRef.update({'comments': comments});
    debugPrint('✅ Reply added successfully');
  }

  // Delete a post (only if user is the author)
  Future<bool> deletePost(String postId) async {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? Data.app.token;
    
    if (userId == null) {
      return false;
    }

    DocumentReference postRef = _postsCollection.doc(postId);
    DocumentSnapshot doc = await postRef.get();
    
    if (!doc.exists) {
      return false;
    }
    
    final postData = doc.data() as Map<String, dynamic>;
    
    // Check if current user is the author
    if (postData['userId'] != userId) {
      return false;
    }
    
    // Delete images from storage
    List<String> imageUrls = List<String>.from(postData['imageUrls'] ?? []);
    for (String url in imageUrls) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (e) {
        debugPrint('Error deleting image: $e');
      }
    }
    
    // Delete post document
    await postRef.delete();
    return true;
  }

  // Get username by user ID
  Future<String> getUsernameById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Check different possible name fields in the user document
        if (userData['displayName'] != null && userData['displayName'].toString().isNotEmpty) {
          return userData['displayName'];
        } else if (userData['name'] != null && userData['name'].toString().isNotEmpty) {
          return userData['name'];
        } else if (userData['userName'] != null && userData['userName'].toString().isNotEmpty) {
          return userData['userName'];
        }
      }
      
      // Fallback to showing user ID with prefix
      return 'User ${userId.substring(0, 4)}';
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return 'User';
    }
  }

  // Get user profile data including username and photo URL
  Future<Map<String, String>> getUserProfileData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String username = 'User';
        String photoUrl = '';
        
        // Check different possible name fields
        if (userData['displayName'] != null && userData['displayName'].toString().isNotEmpty) {
          username = userData['displayName'];
        } else if (userData['name'] != null && userData['name'].toString().isNotEmpty) {
          username = userData['name'];
        } else if (userData['userName'] != null && userData['userName'].toString().isNotEmpty) {
          username = userData['userName'];
        } else {
          username = 'User ${userId.substring(0, 4)}';
        }
        
        // Check different possible photo URL fields
        if (userData['photoUrl'] != null && userData['photoUrl'].toString().isNotEmpty) {
          photoUrl = userData['photoUrl'];
        } else if (userData['profilePic'] != null && userData['profilePic'].toString().isNotEmpty) {
          photoUrl = userData['profilePic'];
        } else if (userData['profileImage'] != null && userData['profileImage'].toString().isNotEmpty) {
          photoUrl = userData['profileImage'];
        }
        
        return {
          'username': username,
          'photoUrl': photoUrl,
        };
      }
      
      return {
        'username': 'User ${userId.substring(0, 4)}',
        'photoUrl': '',
      };
    } catch (e) {
      debugPrint('Error fetching user profile data: $e');
      return {
        'username': 'User',
        'photoUrl': '',
      };
    }
  }

  // Update an existing post
  Future<void> updatePost(
    String postId,
    String description,
    String? brand,
    String? fuelType,
    String? city,
    String? carStyle,
    bool has3DModel,
    List<XFile> newImages,
  ) async {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? Data.app.token;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    DocumentReference postRef = _postsCollection.doc(postId);
    DocumentSnapshot doc = await postRef.get();
    
    if (!doc.exists) {
      throw Exception('Post not found');
    }
    
    final postData = doc.data() as Map<String, dynamic>;
    
    // Check if current user is the author
    if (postData['userId'] != userId) {
      throw Exception('Not authorized to edit this post');
    }

    // Upload new images if any
    List<String> imageUrls = List<String>.from(postData['imageUrls'] ?? []);
    if (newImages.isNotEmpty) {
      // Delete old images
      for (String url in imageUrls) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (e) {
          debugPrint('Error deleting old image: $e');
        }
      }
      
      // Upload new images
      imageUrls = [];
      for (XFile image in newImages) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final Reference ref = _storage.ref().child('post_images/$fileName');
        
        await ref.putData(await image.readAsBytes());
        final String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }

    // Update post document
    await postRef.update({
      'description': description,
      'imageUrls': imageUrls,
      'brand': brand,
      'fuelType': fuelType,
      'city': city,
      'carStyle': carStyle,
      'has3DModel': has3DModel,
      'updatedAt': Timestamp.now(),
    });
  }
} 
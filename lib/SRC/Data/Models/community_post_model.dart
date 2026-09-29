import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Comment {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    this.replies = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    // Safely handle replies list
    List<Reply> replyList = [];
    if (map['replies'] != null) {
      for (var reply in map['replies']) {
        try {
        replyList.add(Reply.fromMap(reply));
        } catch (e) {
          print('Error parsing reply: $e');
        }
      }
    }

    // Safely handle timestamp
    DateTime timestamp;
    try {
      if (map['timestamp'] is Timestamp) {
        timestamp = (map['timestamp'] as Timestamp).toDate();
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }

    return Comment(
      id: map['id'] ?? Uuid().v4(),
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      timestamp: timestamp,
      replies: replyList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }
}

class Reply {
  final String userId;
  final String text;
  final DateTime timestamp;

  Reply({
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  factory Reply.fromMap(Map<String, dynamic> map) {
    // Safely handle timestamp
    DateTime timestamp;
    try {
      if (map['timestamp'] is Timestamp) {
        timestamp = (map['timestamp'] as Timestamp).toDate();
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }

    return Reply(
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class CommunityPost {
  final String? id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String description;
  final List<String> imageUrls;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;
  final String? brand;
  final String? fuelType;
  final String? city;
  final String? carStyle;
  final bool has3DModel;

  CommunityPost({
    this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.description,
    required this.imageUrls,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.brand,
    this.fuelType,
    this.city,
    this.carStyle,
    this.has3DModel = false,
  });

  factory CommunityPost.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Safely handle comments list
    List<Comment> commentsList = [];
    if (data['comments'] != null) {
      for (var comment in data['comments']) {
        try {
          commentsList.add(Comment.fromMap(comment));
        } catch (e) {
          print('Error parsing comment: $e');
        }
      }
    }

    // Safely handle likes list
    List<String> likesList = [];
    if (data['likes'] != null) {
      likesList = List<String>.from(data['likes']);
    }

    // Safely handle imageUrls list
    List<String> imageUrlsList = [];
    if (data['imageUrls'] != null) {
      imageUrlsList = List<String>.from(data['imageUrls']);
    }

    // Safely handle timestamp
    DateTime timestamp;
    try {
      if (data['timestamp'] is Timestamp) {
        timestamp = (data['timestamp'] as Timestamp).toDate();
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }

    return CommunityPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous User',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      description: data['description'] ?? '',
      imageUrls: imageUrlsList,
      timestamp: timestamp,
      likes: likesList,
      comments: commentsList,
      brand: data['brand'],
      fuelType: data['fuelType'],
      city: data['city'],
      carStyle: data['carStyle'],
      has3DModel: data['has3DModel'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'description': description,
      'imageUrls': imageUrls,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'brand': brand,
      'fuelType': fuelType,
      'city': city,
      'carStyle': carStyle,
      'has3DModel': has3DModel,
    };
  }

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? description,
    List<String>? imageUrls,
    List<String>? likes,
    List<Comment>? comments,
    DateTime? timestamp,
    String? brand,
    String? fuelType,
    String? city,
    String? carStyle,
    bool? has3DModel,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      brand: brand ?? this.brand,
      fuelType: fuelType ?? this.fuelType,
      city: city ?? this.city,
      carStyle: carStyle ?? this.carStyle,
      has3DModel: has3DModel ?? this.has3DModel,
    );
  }
}

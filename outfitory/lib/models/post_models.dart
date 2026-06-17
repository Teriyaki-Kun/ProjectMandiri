import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String title; // Properti judul tetap aman di sini
  final String imageUrl;
  final String caption;
  final String category;
  final double latitude;
  final double longitude;
  final int likes;
  final int comments;
  final DateTime createdAt;
  
  // Fitur tambahan untuk menampung data favorit tanpa merusak kode lama
  List<String>? likedBy; 

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.title, // Wajib diisi dalam konstruktor
    required this.imageUrl,
    required this.caption,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.likedBy, 
  });

  factory PostModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return PostModel(
      id: documentId,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      title: map['title'] ?? '', // Membaca data title dari Firestore
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      category: map['category'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      likedBy: map['likedBy'] != null ? List<String>.from(map['likedBy']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'title': title, // PERBAIKAN: Judul sekarang ikut disimpan ke Firestore
      'imageUrl': imageUrl,
      'caption': caption,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy ?? [], 
    };
  }
}
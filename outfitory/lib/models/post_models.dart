class PostModel {
  final String postId;
  final String userId;
  final String imageUrl;
  final String description;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final List<dynamic> favorites;

  PostModel({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.favorites,
  });

  factory PostModel.fromMap(Map<String, dynamic> data) {
    return PostModel(
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      timestamp: data['timestamp'].toDate(),
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      favorites: data['favorites'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'favorites': favorites,
    };
  }
}
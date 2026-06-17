import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outfitory/models/post_models.dart';

class PostService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==========================
  // LOCATION
  // ==========================

  Future<Map<String, double>>
      getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location service tidak aktif',
      );
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak',
      );
    }

    final position =
        await Geolocator
            .getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high,
    );

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }

  // ==========================
  // CREATE POST
  // ==========================

  Future<void> createPost(
    PostModel post,
  ) async {
    await _firestore
        .collection('posts')
        .add(post.toMap());
  }

  // ==========================
  // GET POSTS
  // ==========================

  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PostModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // ==========================
  // GET USER POSTS
  // ==========================

  Stream<List<PostModel>>
      getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PostModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // ==========================
  // LIKE POST
  // ==========================

  Future<void> likePost(
    String postId,
    int currentLikes,
  ) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .update({
      'likes': currentLikes + 1,
    });
  }

  // ==========================
  // DELETE POST
  // ==========================

  Future<void> deletePost(
    String postId,
  ) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .delete();
  }
}
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:outfitory/models/post_models.dart';
import 'package:outfitory/screens/main_screen.dart';


class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final CollectionReference postsRef =
      FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // HEADER HALAMAN FAVORIT
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite, color: Color(0xFF6C63FF)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Koleksi Favorit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Inspirasi gaya busana yang Anda simpan",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AMBIL DATA DARI FIRESTORE SECARA REALTIME
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: postsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan memuat data'));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  final favoritePosts = docs.map((doc) {
                    return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  }).where((post) => post.likedBy?.contains(userId) ?? false).toList();

                  if (favoritePosts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Belum ada post favorit yang disimpan.', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: favoritePosts.length,
                    itemBuilder: (context, index) {
                      final postItem = favoritePosts[index];

                      return GestureDetector(
                        onTap: () {
                          final mainState = context.findAncestorStateOfType<MainScreenState>();
                          if (mainState != null) {
                            mainState.updateSelectedPost(postItem);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: postItem.imageUrl.startsWith('data:image') || !postItem.imageUrl.startsWith('http')
                                      ? Image.memory(
                                          base64Decode(postItem.imageUrl.contains(',') ? postItem.imageUrl.split(',')[1] : postItem.imageUrl),
                                          width: double.infinity, fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          postItem.imageUrl, width: double.infinity, fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image, color: Colors.grey)),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      postItem.title.isNotEmpty ? postItem.title : "Outfit Style",
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            postItem.category.isNotEmpty ? postItem.category : "Fashion",
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ),
                                        const Icon(Icons.favorite, color: Colors.red, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
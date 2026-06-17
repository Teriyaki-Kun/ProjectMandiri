import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:outfitory/models/post_models.dart'; // Impor model PostModel Anda
import 'package:outfitory/screens/main_screen.dart'; // Impor MainScreen untuk mengakses statenya

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // HEADER UTAMA DENGAN GRADASI UNGU - PINK khas Outfitory
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF8B5CF6)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Outfitory",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Share Your Fashion Inspiration",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LIST DATA POSTINGAN DARI FIRESTORE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: posts.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Terjadi kesalahan data'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                      ),
                    );
                  }

                  final data = snapshot.data!.docs;

                  if (data.isEmpty) {
                    return const Center(
                      child: Text('Belum ada inspirasi outfit yang dibagikan.'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75, // Proporsi pas untuk foto OOTD berdiri
                    ),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final doc = data[index];
                      final postMap = doc.data() as Map<String, dynamic>;

                      // Konversi data mentah Firestore Map ke PostModel terstruktur
                      final postItem = PostModel.fromMap(postMap, doc.id);

                      return GestureDetector(
                        // PERBAIKAN NAVIGASI AGAR NAVBAR TIDAK HILANG
                        onTap: () {
                          // Mencari State MainScreen terdekat di susunan pohon widget
                          final mainScreenState =
                              context.findAncestorStateOfType<MainScreenState>();
                          
                          if (mainScreenState != null) {
                            mainScreenState.updateSelectedPost(postItem);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gambar Outfit Terpilih
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: postItem.imageUrl.startsWith('data:image') ||
                                          !postItem.imageUrl.startsWith('http')
                                      ? Image.memory(
                                          base64Decode(postItem.imageUrl.contains(',')
                                              ? postItem.imageUrl.split(',')[1]
                                              : postItem.imageUrl),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          postItem.imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) =>
                                              Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.broken_image,
                                                color: Colors.grey),
                                          ),
                                        ),
                                ),
                              ),
                              
                              // Judul dan Detail Singkat Outfit di bagian bawah kartu
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      postItem.title.isNotEmpty
                                          ? postItem.title
                                          : "Outfit Style",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      postItem.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
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


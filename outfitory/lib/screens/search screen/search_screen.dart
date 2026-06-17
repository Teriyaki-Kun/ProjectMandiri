import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:outfitory/models/post_models.dart';
import 'package:outfitory/screens/main_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cari Outfit", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Cari berdasarkan judul atau kategori...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // HASIL PENCARIAN
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allPosts = snapshot.data!.docs.map((doc) => 
                  PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
                ).toList();

                // Filter logika berdasarkan query
                final filteredPosts = allPosts.where((post) => 
                  post.title.toLowerCase().contains(_searchQuery) ||
                  post.category.toLowerCase().contains(_searchQuery)
                ).toList();

                if (_searchQuery.isEmpty) {
                  return const Center(child: Text("Mulai cari inspirasi fashionmu!"));
                }

                if (filteredPosts.isEmpty) {
                  return const Center(child: Text("Hasil tidak ditemukan"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return GestureDetector(
                      onTap: () {
                        final mainState = context.findAncestorStateOfType<MainScreenState>();
                        mainState?.updateSelectedPost(post);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(post.imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
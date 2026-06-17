import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outfitory/models/post_models.dart';

class DetailScreen extends StatefulWidget {
  final PostModel post;
  final VoidCallback onBack;

  const DetailScreen({
    super.key,
    required this.post,
    required this.onBack,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController commentController = TextEditingController();
  List<String> comments = [];
  
  bool isFavorited = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null && widget.post.likedBy != null) {
      isFavorited = widget.post.likedBy!.contains(currentUserId);
    }
  }

  Future<void> toggleFavorite() async {
    if (currentUserId == null) return;

    final originalState = isFavorited;
    setState(() {
      isFavorited = !isFavorited;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

      if (isFavorited) {
        await docRef.update({
          'likedBy': FieldValue.arrayUnion([currentUserId]),
          'likes': FieldValue.increment(1),
        });
        widget.post.likedBy ??= [];
        widget.post.likedBy!.add(currentUserId!);
      } else {
        await docRef.update({
          'likedBy': FieldValue.arrayRemove([currentUserId]),
          'likes': FieldValue.increment(-1),
        });
        widget.post.likedBy?.remove(currentUserId);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? "Ditambahkan ke Favorit!" : "Dihapus dari Favorit",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: isFavorited ? const Color(0xFF6C63FF) : Colors.grey.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        isFavorited = originalState;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan favorit: $e")),
      );
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    Widget buildPostImage(String imageSrc) {
      if (imageSrc.startsWith('data:image') || !imageSrc.startsWith('http')) {
        try {
          String cleanBase64 = imageSrc.contains(',') ? imageSrc.split(',')[1] : imageSrc;
          return Image.memory(
            base64Decode(cleanBase64),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          );
        } catch (e) {
          return Container(
            height: 250,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        }
      } else {
        return Image.network(
          imageSrc,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 250,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Post',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : Colors.white,
              size: 26,
            ),
            onPressed: toggleFavorite,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPostImage(post.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title.isNotEmpty ? post.title : "Outfit Inspiration",
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 4),
                      Text(
                        post.username.isNotEmpty ? "by @${post.username}" : "by @User",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (post.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post.category,
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text("Keterangan", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    post.caption, 
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.4, color: Colors.black54)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
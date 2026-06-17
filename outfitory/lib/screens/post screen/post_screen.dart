import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outfitory/services/post_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outfitory/models/post_models.dart';

class PostScreen extends StatefulWidget {
  // Callback untuk memindahkan halaman secara otomatis ke Home setelah sukses posting
  final VoidCallback? onPostSuccess;

  const PostScreen({super.key, this.onPostSuccess});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostService _postService = PostService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController captionController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  
  Uint8List? imageBytes;
  File? selectedImage;
  String? _base64Image; // Variabel penampung teks enkripsi gambar asli
  String? selectedCategory;
  double? latitude;
  double? longitude;
  bool isSubmitting = false;
  bool isGettingLocation = false;

  final List<String> categories = [
    "Casual",
    "Streetwear",
    "Vintage",
    "Formal",
    "Sport",
    "Y2K",
    "Luxury",
  ];

  @override
  void dispose() {
    titleController.dispose();
    captionController.dispose();
    super.dispose();
  }

  // Mengambil gambar dari galeri, mengompresi, lalu mengubahnya menjadi Base64
  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Kompresi kualitas gambar agar muat di database
        maxWidth: 1080,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          selectedImage = File(image.path);
          imageBytes = bytes;
          _base64Image = base64Encode(bytes); // Mengonversi gambar menjadi teks Base64
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> getLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      final result = await _postService.getCurrentLocation();
      setState(() {
        latitude = result['latitude'];
        longitude = result['longitude'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil lokasi: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isGettingLocation = false;
      });
    }
  }

  Future<void> createPost() async {
    if (_base64Image == null ||
        titleController.text.trim().isEmpty ||
        captionController.text.trim().isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data input wajib diisi!")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Sesi login berakhir, silakan login ulang.");

      // Menyusun struktur data PostModel menggunakan String Base64 dari gambar asli
      final post = PostModel(
        id: '',
        userId: user.uid,
        username: user.displayName ?? user.email?.split('@')[0] ?? "Anonymous",
        title: titleController.text.trim(),
        caption: captionController.text.trim(),
        imageUrl: _base64Image!, // Memasukkan string base64 ke field imageUrl dokumen
        category: selectedCategory!,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
      );

      // Mengirimkan objek data menuju Cloud Firestore
      await _postService.createPost(post);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Outfit Berhasil Diposting!"),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );

        // Reset isi formulir setelah unggahan berhasil
        setState(() {
          selectedImage = null;
          imageBytes = null;
          _base64Image = null;
          titleController.clear();
          captionController.clear();
          selectedCategory = null;
          latitude = null;
          longitude = null;
        });

        // Memicu perpindahan halaman kembali ke beranda utama
        if (widget.onPostSuccess != null) {
          widget.onPostSuccess!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Post Your Outfit",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: isSubmitting ? null : pickImage,
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                ),
                child: imageBytes == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 38, color: Color(0xFF8B5CF6)),
                          SizedBox(height: 6),
                          Text("Pilih Foto Outfit Terbaikmu", style: TextStyle(color: Color(0xFF8B5CF6))),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 18),

            Text("Judul Outfit", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: titleController,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                hintText: "Contoh: Jaket Denim Casual Style",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text("Kategori Gaya", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF8B5CF6),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  onSelected: isSubmitting
                      ? null
                      : (bool select) {
                          setState(() {
                            selectedCategory = select ? cat : null;
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text("Keterangan Outfit / Caption", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: captionController,
              enabled: !isSubmitting,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Tuliskan detail busana atau kombinasi pakaianmu...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text("Lokasi OOTD", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    latitude != null && longitude != null
                        ? "Koordinat: ${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}"
                        : "Lokasi belum disematkan",
                    style: TextStyle(color: latitude != null ? Colors.green : Colors.grey, fontSize: 13),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isSubmitting || isGettingLocation ? null : getLocation,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                  icon: isGettingLocation
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 16, color: Colors.white),
                  label: const Text("Ambil", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            "Post Outfit",
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
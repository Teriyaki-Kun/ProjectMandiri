import 'dart:convert'; 
import 'dart:io'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; 
class ProfileEditResult {
  final String username;
  final String bio;
  final String? profileImage; 

  ProfileEditResult({
    required this.username,
    required this.bio,
    this.profileImage, 
  });
}

class ProfileEditScreen extends StatefulWidget {
  final String initialUsername;
  final String initialBio;
  final String? initialImage; 

  const ProfileEditScreen({
    super.key,
    required this.initialUsername,
    required this.initialBio,
    this.initialImage, 
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  String? _base64Image; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _bioController = TextEditingController(text: widget.initialBio);
    _base64Image = widget.initialImage; 
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompres kualitas gambar agar string data tidak terlalu besar
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    }
  }

  Future<void> _saveProfile() async {
    final newUsername = _usernameController.text.trim();
    final newBio = _bioController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pengguna tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newUsername);
        await user.reload(); 
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
        
        // MODIFIKASI: Mengembalikan data beserta foto profil barunya
        Navigator.pop(
          context,
          ProfileEditResult(username: newUsername, bio: newBio, profileImage: _base64Image),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
          'Edit Profil',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                      backgroundImage: _base64Image != null && _base64Image!.startsWith('data:image')
                          ? MemoryImage(base64Decode(_base64Image!.split(',')[1]))
                          : null,
                      child: _base64Image == null
                          ? const Icon(Icons.person, size: 65, color: Color(0xFF8B5CF6))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEC4899),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            Text(
              "Nama Pengguna",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _usernameController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Masukkan nama barumu',
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF8B5CF6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              "Bio Fashion",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              enabled: !_isLoading,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tuliskan bio fashion atau status OOTD terbarumu...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Icon(Icons.wb_incandescent_outlined, color: Color(0xFF8B5CF6)),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 35),
            
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
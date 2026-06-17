import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileEditResult {
  final String username;
  final String bio;

  ProfileEditResult({
    required this.username,
    required this.bio,
  });
}

class ProfileEditScreen extends StatefulWidget {
  final String initialUsername;
  final String initialBio;

  const ProfileEditScreen({
    super.key,
    required this.initialUsername,
    required this.initialBio,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
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
        // Memperbarui nama tampilan di database Firebase Authentication
        await user.updateDisplayName(newUsername);
        await user.reload(); // Memuat ulang data pengguna agar tersinkronisasi
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
        
        // Menutup halaman dan mengembalikan data baru ke ProfileScreen
        Navigator.pop(
          context,
          ProfileEditResult(username: newUsername, bio: newBio),
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
            const SizedBox(height: 10),
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
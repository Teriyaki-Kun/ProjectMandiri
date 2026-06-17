import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String _email = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _email = user.email ?? 'Tidak ada email terhubung';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kata sandi baru minimal harus 6 karakter!")),
      );
      return;
    }

    try {
      setState(() {
        _loading = true;
      });

      // Memperbarui sandi akun langsung di platform Firebase Auth
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kata sandi berhasil diubah!"),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
      }
      _passwordController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengubah kata sandi: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_email.isEmpty || _email.contains('Tidak ada email')) return;

    try {
      setState(() {
        _loading = true;
      });

      // Mengirimkan link reset otomatis ke kotak masuk email pengguna
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tautan setel ulang sandi berhasil dikirim ke $_email"),
            backgroundColor: const Color(0xFFEC4899),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim link reset: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Keamanan Akun",
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
            // Kartu Informasi Email Terdaftar
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.email, color: Color(0xFF8B5CF6)),
                ),
                title: Text("Email Terhubung", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade500)),
                subtitle: Text(_email, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
              ),
            ),
            const SizedBox(height: 25),

            Text(
              "Ganti Kata Sandi Baru",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: true,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: "Masukkan minimal 6 karakter sandi",
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8B5CF6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Utama Ganti Sandi Manis
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Ubah Kata Sandi",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Sekunder Kirim Link Reset Email
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _resetPassword,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEC4899), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.send_rounded, color: Color(0xFFEC4899), size: 18),
                label: Text(
                  "Kirim Link Reset Password ke Email",
                  style: GoogleFonts.poppins(color: Color(0xFFEC4899), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
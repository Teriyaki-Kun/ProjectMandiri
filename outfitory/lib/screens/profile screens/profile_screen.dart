import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outfitory/main.dart'; // Mengimpor appThemeMode dari main.dart
import 'package:outfitory/screens/login screen/login_screen.dart';
import 'package:outfitory/screens/profile screens/profile_edit_screen.dart';
import 'package:outfitory/screens/profile screens/security_screen.dart';

class ProfileScreen extends StatefulWidget {
  // Menerima notifier tema, default menggunakan variabel global appThemeMode
  final ValueNotifier<ThemeMode> themeModeNotifier;

  ProfileScreen({super.key, ValueNotifier<ThemeMode>? themeModeNotifier})
      : themeModeNotifier = themeModeNotifier ?? appThemeMode;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Fashionista';
  String _bio = 'Fashion Enthusiast | Loving OOTD Styles';
  String _email = 'user@outfitory.com';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _username = user.displayName ?? user.email?.split('@')[0] ?? 'User_only';
        _email = user.email ?? 'test@gmail.com';
      });
    }
  }

  // Helper untuk mengecek apakah aplikasi sedang dalam mode gelap
  bool get _isDarkMode => widget.themeModeNotifier.value == ThemeMode.dark;

  // Fungsi pengubah status tema saat sakelar ditekan
  void _toggleTheme(bool value) {
    setState(() {
      widget.themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Penyesuaian warna teks & background mengikuti kondisi tema
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final cardColor = _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar Profil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                    child: const Icon(Icons.person, size: 65, color: Color(0xFF8B5CF6)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEC4899),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Identitas User
            Text(
              _username,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              _bio,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 25),

            // Opsi Menu Informasi & Keamanan
            _buildMenuCard(
              context,
              icon: Icons.email_outlined,
              title: "Email",
              subtitle: _email,
              cardColor: cardColor,
              onTap: null,
            ),
            _buildMenuCard(
              context,
              icon: Icons.lock_outline,
              title: "Keamanan Akun",
              subtitle: "Ubah atau atur ulang kata sandi",
              cardColor: cardColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecurityScreen()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.edit_outlined,
              title: "Edit Profil",
              subtitle: "Perbarui nama panggilan dan bio fashion",
              cardColor: cardColor,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(
                      initialUsername: _username,
                      initialBio: _bio,
                    ),
                  ),
                );

                if (result != null && result is ProfileEditResult) {
                  setState(() {
                    _username = result.username;
                    _bio = result.bio;
                  });
                }
              },
            ),

            // TAMBAHAN: Card Pengaturan Fitur Dark Mode
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              color: cardColor,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                value: _isDarkMode,
                onChanged: _toggleTheme,
                title: Text(
                  "Mode Gelap (Dark Mode)",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                ),
                subtitle: Text(
                  "Kurangi ketegangan mata di malam hari",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Tombol Keluar / Logout
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF8B5CF6)),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 14, 
            color: _isDarkMode ? Colors.white : Colors.black87
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
        trailing: onTap != null 
            ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
          shadowColor: Colors.red.withOpacity(0.2),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        label: Text(
          'Keluar dari Akun',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
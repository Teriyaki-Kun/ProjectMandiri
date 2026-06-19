import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // Impor Firebase Auth
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outfitory/screens/main_screen.dart';
import 'package:outfitory/screens/login screen/login_screen.dart'; // Sesuaikan path ke LoginScreen Anda

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Menggunakan TickerProviderStateMixin untuk mengontrol animasi denyut (scale)
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi pengontrol animasi denyut (durasi 1.2 detik per denyut)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Membuat kurva animasi membesar-mengecil yang halus (dari 0.93 hingga 1.07 dari ukuran asli)
      _scaleAnimation = Tween<double>(begin: 0.93, end: 1.07).animate(
        CurvedAnimation(
          parent: _scaleController,
          curve: Curves.easeInOut,
        ),
      );

      // Mulai animasi berulang pada controller (repeat ada di AnimationController, bukan Animation)
      _scaleController.repeat(reverse: true);

    // 2. Beri jeda singkat untuk memunculkan teks judul secara halus (fade-in)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _textOpacity = 1.0;
        });
      }
    });

    // 3. Timer otomatis 3 detik dengan pengecekan sesi login Firebase Auth
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Jika pengguna sudah login sebelumnya, arahkan ke halaman utama
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // Jika belum login atau setelah dipaksa logout, wajib ke Halaman Login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // Wajib di-dispose agar tidak terjadi kebocoran memori (memory leak)
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF8B5CF6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PERUBAHAN DI SINI: Menggunakan ScaleTransition agar logo berdenyut lembut
              ScaleTransition(
                scale: _scaleAnimation, // Mengontrol perbesaran logo
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.checkroom_rounded, // Ikon baju/fashion Anda
                    size: 80,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Animasi Teks Judul
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _textOpacity,
                child: Text(
                  "Outfitory",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Animasi Subtitle
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1200),
                opacity: _textOpacity,
                child: Text(
                  "Your Fashion Inspiration Hub",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // Indikator Loading Minimalis di paling bawah
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
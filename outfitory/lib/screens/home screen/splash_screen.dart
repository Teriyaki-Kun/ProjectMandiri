import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outfitory/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Tambahkan TickerProviderStateMixin agar kelas ini bisa mengontrol animasi berputar
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi pengontrol animasi putar (durasi 1 putaran penuh = 4 detik)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(); // Fungsi ..repeat() membuat logo berputar terus-menerus tanpa henti

    // 2. Beri jeda singkat untuk memunculkan teks judul secara halus (fade-in)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _textOpacity = 1.0;
        });
      }
    });

    // 3. Timer otomatis pindah halaman ke MainScreen setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Wajib di-dispose agar tidak terjadi kebocoran memori (memory leak)
    _rotationController.dispose();
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
              // ANIMASI LOGO BERPUTAR SECARA LOOP (Mirip JelajahYuk)
              RotationTransition(
                turns: _rotationController, // Mengontrol perputaran roda logo
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
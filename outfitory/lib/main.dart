import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahkan ini
import 'firebase_options.dart'; // Tambahkan ini (file hasil dari flutterfire configure)
import 'package:outfitory/screens/home screen/splash_screen.dart';
import 'package:outfitory/firebase_options.dart';

// 1. Buat Notifier global untuk menampung status tema aplikasi
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  // Tambahkan baris ini agar binding siap sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Bungkus dengan ValueListenableBuilder agar aplikasi langsung merespon saat tema diganti
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Outfitory',
          debugShowCheckedModeBanner: false,
          
          // Pengaturan skema warna tema terang (Light)
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey.shade50,
          ),
          
          // Pengaturan skema warna tema gelap (Dark)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
          ),
          
          home: const SplashScreen(),
        );
      },
    );
  }
}
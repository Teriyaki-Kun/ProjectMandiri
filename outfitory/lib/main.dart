import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'package:outfitory/screens/home screen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signOut(); 
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
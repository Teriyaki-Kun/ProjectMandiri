import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:outfitory/screens/register%20screen/register_screen.dart';
import 'package:outfitory/screens/main_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email dan Password wajib diisi",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login gagal";

      switch (e.code) {
        case "user-not-found":
          message = "User tidak ditemukan";
          break;

        case "wrong-password":
          message = "Password salah";
          break;

        case "invalid-email":
          message = "Format email tidak valid";
          break;

        case "invalid-credential":
          message = "Email atau password salah";
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFFEC4899),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.checkroom,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "Outfitory",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  "Express Your Style",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              const Text(
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Masukkan email",
                  prefixIcon:
                      const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: "Masukkan password",
                  prefixIcon:
                      const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF8B5CF6),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum punya akun?",
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Daftar",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
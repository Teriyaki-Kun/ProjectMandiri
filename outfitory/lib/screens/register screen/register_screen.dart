import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController =
      TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text
            .trim()
            .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Password tidak cocok"),
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password minimal 6 karakter",
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
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Registrasi berhasil"),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Registrasi gagal";

      switch (e.code) {
        case "email-already-in-use":
          message =
              "Email sudah digunakan";
          break;

        case "invalid-email":
          message =
              "Format email tidak valid";
          break;

        case "weak-password":
          message =
              "Password terlalu lemah";
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(25),
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.checkroom,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Join Outfitory",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                "Create your fashion community account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Full Name",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText:
                    "Masukkan nama lengkap",
                prefixIcon:
                    const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                    const Icon(Icons.email),
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
                hintText:
                    "Masukkan password",
                prefixIcon:
                    const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility
                        : Icons
                            .visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Confirm Password",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  confirmPasswordController,
              obscureText:
                  obscureConfirmPassword,
              decoration: InputDecoration(
                hintText:
                    "Konfirmasi password",
                prefixIcon:
                    const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility
                        : Icons
                            .visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : register,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                          0xFF8B5CF6),
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
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
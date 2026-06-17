import 'package:flutter/material.dart';
import 'package:outfitory/models/post_models.dart';
import 'package:outfitory/screens/detail%20screen/detail_screen.dart';
import 'package:outfitory/screens/favorite%20screen/favorite_screen.dart';
import 'package:outfitory/screens/home%20screen/home_screen.dart';
import 'package:outfitory/screens/post%20screen/post_screen.dart';
import 'package:outfitory/screens/profile%20screens/profile_screen.dart';
import 'package:outfitory/screens/search%20screen/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState(); // PERUBAHAN: Hapus _ di sini
}

// PERUBAHAN: Hapus tanda _ agar kelas State ini menjadi Publik dan terdeteksi di HomeScreen
class MainScreenState extends State<MainScreen> { 
  int currentIndex = 0;
  PostModel? selectedPost; 

  // Fungsi pembantu publik untuk mengubah postingan aktif dari HomeScreen
  void updateSelectedPost(PostModel post) {
    setState(() {
      selectedPost = post;
      currentIndex = 0; // Tetap kunci di tab beranda saat melihat detail
    });
  }

  // Membuat getter halaman dinamis agar widget di dalam list halaman tidak kaku
  List<Widget> get pages => [
    const HomeScreen(),
    const FavoriteScreen(),
    const PostScreen(),
    const SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    
    if (currentIndex == 0 && selectedPost != null) {
      bodyWidget = DetailScreen(
        post: selectedPost!,
        onBack: () {
          setState(() {
            selectedPost = null; // Reset untuk kembali menampilkan list utama
          });
        },
      );
    } else {
      bodyWidget = pages[currentIndex];
    }

    return Scaffold(
      body: bodyWidget,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5CF6),
        onPressed: () {
          setState(() {
            selectedPost = null; 
            currentIndex = 2;
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.home, label: "Home", index: 0),
              _navItem(icon: Icons.favorite, label: "Favorite", index: 1),
              const SizedBox(width: 40),
              _navItem(icon: Icons.search, label: "Search", index: 3),
              _navItem(icon: Icons.person, label: "Profile", index: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPost = null; 
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey),
          Text(label, style: TextStyle(color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
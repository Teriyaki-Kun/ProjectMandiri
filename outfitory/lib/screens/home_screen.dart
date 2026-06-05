import 'package:flutter/material.dart';
import 'package:outfitory/models/post_models.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<PostModel> posts = [
    PostModel(
      postId: '1',
      userId: 'u1',
      imageUrl: 'https://picsum.photos/300',
      description: 'Casual outfit today',
      timestamp: DateTime.now(),
      latitude: -2.9761,
      longitude: 104.7754,
      favorites: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StyleSpot')),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          return Card(
            child: ListTile(
              leading: Image.network(post.imageUrl, width: 50),
              title: Text(post.description),
              subtitle: Text(post.timestamp.toString()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(post: post),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
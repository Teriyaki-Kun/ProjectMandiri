import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController captionController = TextEditingController();

  void uploadPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post Uploaded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Text('Image Picker Here'),
              ),
            ),
            TextField(
              controller: captionController,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
            ),
            ElevatedButton(
              onPressed: uploadPost,
              child: const Text('Upload'),
            )
          ],
        ),
      ),
    );
  }
}
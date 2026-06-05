import 'package:flutter/material.dart';
import 'package:outfitory/models/post_models.dart';


class DetailScreen extends StatefulWidget {
  final PostModel post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController commentController = TextEditingController();

  List<String> comments = [];

  void addComment() {
    setState(() {
      comments.add(commentController.text);
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(post.imageUrl),
            Text(post.description),
            Text('Lat: ${post.latitude}'),
            Text('Lng: ${post.longitude}'),

            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Add comment',
              ),
            ),

            ElevatedButton(
              onPressed: addComment,
              child: const Text('Comment'),
            ),

            ...comments.map((comment) => ListTile(
                  title: Text(comment),
                )),
          ],
        ),
      ),
    );
  }
}
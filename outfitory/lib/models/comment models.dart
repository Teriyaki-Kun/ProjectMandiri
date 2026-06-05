class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String comment;
  final String? replyTo;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.comment,
    this.replyTo,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data) {
    return CommentModel(
      commentId: data['commentId'] ?? '',
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      comment: data['comment'] ?? '',
      replyTo: data['replyTo'],
      timestamp: data['timestamp'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'comment': comment,
      'replyTo': replyTo,
      'timestamp': timestamp,
    };
  }
}
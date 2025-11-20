import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinemapedia/domain/entities/comment.dart';

class CommentsRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener comentarios de una película en tiempo real
  Stream<List<Comment>> getCommentsByMovie(String movieId) {
    return _firestore
        .collection('comments')
        .where('movieId', isEqualTo: movieId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Comment(
                id: doc.id,
                movieId: data['movieId'],
                userId: data['userId'],
                userName: data['userName'],
                text: data['text'],
                timestamp: (data['timestamp'] as Timestamp).toDate(),
              );
            }).toList());
  }

  // Agregar un nuevo comentario
  Future<void> addComment({
    required String movieId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    await _firestore.collection('comments').add({
      'movieId': movieId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
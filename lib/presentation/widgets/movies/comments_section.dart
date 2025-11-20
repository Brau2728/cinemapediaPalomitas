import 'package:cinemapedia/presentation/providers/auth/auth_provider.dart';
import 'package:cinemapedia/presentation/providers/comments/comments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha (necesitas importar intl)

class CommentsSection extends ConsumerStatefulWidget {
  final String movieId;

  const CommentsSection({super.key, required this.movieId});

  @override
  CommentsSectionState createState() => CommentsSectionState();
}

class CommentsSectionState extends ConsumerState<CommentsSection> {
  final _commentController = TextEditingController();

  void _submitComment() {
    final user = ref.read(authStateProvider).value;
    if (user == null) return; // O mostrar mensaje de "inicia sesión"

    if (_commentController.text.trim().isEmpty) return;

    ref.read(commentsRepositoryProvider).addComment(
          movieId: widget.movieId,
          userId: user.uid,
          userName: user.email ?? 'Anónimo', // O user.displayName si lo tienes
          text: _commentController.text.trim(),
        );

    _commentController.clear();
    FocusScope.of(context).unfocus(); // Cerrar teclado
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsyncValue = ref.watch(commentsByMovieProvider(widget.movieId));
    final user = ref.watch(authStateProvider).value;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comentarios',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // Input de comentario
          if (user != null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu opinión...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                )
              ],
            )
          else
            const Center(child: Text('Inicia sesión para comentar')),

          const SizedBox(height: 20),

          // Lista de comentarios
          commentsAsyncValue.when(
            data: (comments) {
              if (comments.isEmpty) {
                return const Center(child: Text('Sé el primero en comentar.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Para que funcione dentro del ScrollView principal
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(comment.userName[0].toUpperCase())),
                      title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.text),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().add_Hm().format(comment.timestamp),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error al cargar comentarios: $e')),
          ),
          // Espacio extra al final para que no choque con el borde
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
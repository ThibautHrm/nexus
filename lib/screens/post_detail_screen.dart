import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/comment_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/services/firebase_service.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  final String groupId;

  const PostDetailScreen(
      {super.key, required this.post, required this.groupId});

  @override
  PostDetailScreenState createState() => PostDetailScreenState();
}

class PostDetailScreenState extends State<PostDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _commentList = [];
  bool _isLoading = true;
  String _commentContent = '';
  final TextEditingController _commentController = TextEditingController();
  // Vérifie si déjà liké par l'utilisateur
  bool isUpvotedPost = false;

  @override
  void initState() {
    super.initState();
    isUpvotedPost =
        widget.post.upvotedBy.contains(_firebaseService.getCurrentUser()!.uid);
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      List<CommentModel> comments = await _firebaseService.getCommentsForPost(
          widget.groupId, widget.post.id);

      // Récupère les données utilisateurs et photo de profil pour chaque commentaires
      List<Map<String, dynamic>> commentDataList = [];
      for (var comment in comments) {
        UserModel? user = await _firebaseService.getUser(comment.auteurUid);
        if (user != null) {
          commentDataList.add({
            'comment': comment,
            'user': user,
          });
        }
      }

      setState(() {
        _commentList = commentDataList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _commentList = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentContent.isNotEmpty) {
      CommentModel comment = CommentModel(
        id: '',
        contenu: _commentContent,
        auteurUid: _firebaseService.getCurrentUser()!.uid,
        dateCreation: DateTime.now(),
      );

      await _firebaseService.addCommentToPost(
          widget.groupId, widget.post.id, comment);
      _loadComments();
      setState(() {
        _commentController.clear();
        _commentContent = '';
      });
    }
  }

  Future<void> _toggleUpvoteComment(String commentId, String userId) async {
    await _firebaseService.toggleUpvoteComment(
        widget.groupId, widget.post.id, commentId, userId);
    _loadComments(); // Rafraîchit les commentaires après un upvote
  }

  Future<void> _toggleUpvotePost() async {
    await _firebaseService.toggleUpvotePost(
        widget.groupId, widget.post.id, _firebaseService.getCurrentUser()!.uid);
    setState(() {
      isUpvotedPost = !isUpvotedPost;
      widget.post.upvotes += isUpvotedPost ? 1 : -1;
    });
  }

  // Widget pour chaque commentaire
  Widget _buildCommentItem(
      Map<String, dynamic> commentData, bool isCurrentUser) {
    CommentModel comment = commentData['comment'];
    UserModel user = commentData['user'];

    bool isUpvoted =
        comment.upvotedBy.contains(_firebaseService.getCurrentUser()!.uid);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isCurrentUser ? Colors.blue[50] : Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: user.photoProfil != null
                ? NetworkImage(user.photoProfil!)
                : null,
            child: user.photoProfil == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          title: Text(
            user.nom,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.contenu),
              const SizedBox(height: 4.0),
              Text(
                DateFormat('dd MMM yyyy à HH:mm').format(comment.dateCreation),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          trailing: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 25,
                  icon: Icon(
                    Icons.thumb_up,
                    color: isUpvoted ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    _toggleUpvoteComment(
                        comment.id, _firebaseService.getCurrentUser()!.uid);
                  },
                ),
                Text(
                  "${comment.upvotes}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.post.titre,
          style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              Icons.thumb_up,
              color: isUpvotedPost ? Colors.blue : Colors.black,
              size: 24,
            ),
            onPressed: _toggleUpvotePost,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "${widget.post.upvotes}",
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Description du post
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(widget.post.imageUrl),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      widget.post.description,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy à HH:mm')
                          .format(widget.post.dateCreation),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // Liste des commentaires
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_commentList.isEmpty)
              const Center(child: Text("Aucun commentaire."))
            else
              ListView.builder(
                shrinkWrap: true, // Limite la taille de la listeview
                physics:
                    const NeverScrollableScrollPhysics(), // Désactive le scroll dans la listview
                itemCount: _commentList.length,
                itemBuilder: (context, index) {
                  bool isCurrentUser = _commentList[index]['user'].uid ==
                      _firebaseService.getCurrentUser()!.uid;
                  return _buildCommentItem(_commentList[index], isCurrentUser);
                },
              ),
            // Champs de saisie de commentaire
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Commenter',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _commentContent = value;
                        });
                      },
                      controller: _commentController,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

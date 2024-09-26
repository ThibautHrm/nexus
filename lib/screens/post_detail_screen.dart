import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/comment_model.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    _loadComments();
  }

  Future<void> _toggleUpvotePost() async {
    await _firebaseService.toggleUpvotePost(
        widget.groupId, widget.post.id, _firebaseService.getCurrentUser()!.uid);
    setState(() {
      isUpvotedPost = !isUpvotedPost;
      widget.post.upvotes += isUpvotedPost ? 1 : -1;
    });
  }

  Future<void> _confirmDeleteComment(
      String commentId, String userId, CommentModel comment) async {
    final confirmation = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Confirmation de suppression",
            style:
                TextStyle(fontFamily: 'Questrial', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Voulez-vous vraiment supprimer ce commentaire ?",
            style: TextStyle(fontFamily: 'Questrial'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Annuler",
                style: TextStyle(
                  fontFamily: 'Questrial',
                  color: AppColors.secondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Supprimer",
                style: TextStyle(
                  fontFamily: 'Questrial',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await _deleteComment(commentId, userId, comment);
    }
  }

  Future<void> _deleteComment(
      String commentId, String userId, CommentModel comment) async {
    await _firebaseService.deleteComment(
        widget.groupId, widget.post.id, commentId);
    await _firebaseService.decrementUserCommentCount(userId);
    _loadComments();
  }

  Widget _buildCommentItem(
      Map<String, dynamic> commentData, bool isCurrentUser) {
    CommentModel comment = commentData['comment'];
    UserModel user = commentData['user'];
    bool isUpvoted =
        comment.upvotedBy.contains(_firebaseService.getCurrentUser()!.uid);

    return GestureDetector(
      onLongPress: isCurrentUser
          ? () => _confirmDeleteComment(comment.id, user.uid, comment)
          : null,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        color: isCurrentUser
            ? AppColors.primary.withOpacity(0.1)
            : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec les infos user et la date
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: user.photoProfil ?? '',
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 20,
                    ),
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 20,
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Questrial',
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy à HH:mm')
                              .format(comment.dateCreation),
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Questrial',
                            color: isCurrentUser
                                ? AppColors.textDark
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Comment content
              Text(
                comment.contenu,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Questrial',
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              // Likes et partage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up_alt_rounded,
                          color: isUpvoted
                              ? (isCurrentUser ? Colors.white : Colors.green)
                              : (isCurrentUser ? Colors.white : Colors.grey),
                        ),
                        onPressed: () {
                          _toggleUpvoteComment(comment.id,
                              _firebaseService.getCurrentUser()!.uid);
                        },
                      ),
                      Text(
                        "${comment.upvotes}",
                        style: const TextStyle(
                          fontFamily: 'Questrial',
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: isCurrentUser ? Colors.white : AppColors.primary,
                    ),
                    onPressed: () {
                      Share.share(comment.contenu);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.post.titre,
          style: const TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        actions: [
          IconButton(
            icon: Icon(
              Icons.thumb_up_alt_rounded,
              color: isUpvotedPost ? Colors.green : Colors.grey,
            ),
            onPressed: _toggleUpvotePost,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "${widget.post.upvotes}",
                style: const TextStyle(
                  fontFamily: 'Questrial',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset + 80),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.post.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: widget.post.imageUrl,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image, size: 100),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Questrial',
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMM yyyy à HH:mm')
                              .format(widget.post.dateCreation),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontFamily: 'Questrial',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_commentList.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Aucun commentaire pour le moment.",
                        style: TextStyle(fontFamily: 'Questrial'),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _commentList.length,
                    itemBuilder: (context, index) {
                      bool isCurrentUser = _commentList[index]['user'].uid ==
                          _firebaseService.getCurrentUser()!.uid;
                      return _buildCommentItem(
                          _commentList[index], isCurrentUser);
                    },
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.backgroundLight,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Commenter...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
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
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

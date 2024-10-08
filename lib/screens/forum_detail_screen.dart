import 'package:flutter/material.dart';
import 'package:nexus/models/group_model.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/screens/add_post_screen.dart';
import 'package:nexus/screens/post_detail_screen.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  GroupDetailScreenState createState() => GroupDetailScreenState();
}

class GroupDetailScreenState extends State<GroupDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<PostModel> _postList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      List<PostModel> posts =
          await _firebaseService.getPostsForGroup(widget.group.id);
      setState(() {
        _postList = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _postList = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToPostDetail(PostModel post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          post: post,
          groupId: widget.group.id,
        ),
      ),
    );
  }

  Future<void> _navigateToAddPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(groupId: widget.group.id),
      ),
    );

    if (result == true) {
      _loadPosts();
    }
  }

  Future<void> _deletePost(PostModel post) async {
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
            "Voulez-vous vraiment supprimer ce post et ses commentaires associés ?",
            style: TextStyle(fontFamily: 'Questrial'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Annuler",
                style: TextStyle(
                    fontFamily: 'Questrial', color: AppColors.secondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Supprimer",
                style: TextStyle(fontFamily: 'Questrial', color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await _firebaseService.deletePostWithCommentsAndImage(
          widget.group.id, post);
      _loadPosts();
    }
  }

  // Gestion de l'overflow du texte avec des "..."
  String _getShortDescription(String description) {
    const int maxLength = 80;
    return description.length > maxLength
        ? '${description.substring(0, maxLength)}...'
        : description;
  }

  // Gestion de l'affichage des tags avec une couleur unique et une icône
  Map<String, dynamic> _getTagProperties(String tag) {
    switch (tag) {
      case 'WIS':
        return {'color': AppColors.primary, 'icon': Icons.school};
      case 'DEVOPS':
        return {'color': Colors.green, 'icon': Icons.computer};
      case 'SYSOPS':
        return {'color': Colors.purple, 'icon': Icons.settings};
      case 'IA':
        return {'color': Colors.orange, 'icon': Icons.memory};
      case 'Aide':
        return {'color': Colors.redAccent, 'icon': Icons.help};
      case 'Général':
        return {'color': Colors.teal, 'icon': Icons.chat};
      default:
        return {'color': Colors.grey, 'icon': Icons.label};
    }
  }

  // Widget pour chaque post
  Widget _buildPostItem(PostModel post) {
    bool isAuthor = post.auteurUid == _firebaseService.getCurrentUser()!.uid;
    final tagProperties = _getTagProperties(post.tag);

    return GestureDetector(
      onLongPress: isAuthor ? () => _deletePost(post) : null,
      onTap: () => _navigateToPostDetail(post),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              // Image à gauche, taille fixe et ajustement de l'image (en cover)
              if (post.imageUrl.isNotEmpty)
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Titre du post
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          post.titre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black87,
                            fontFamily: "Questrial",
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          // Auteur du post (avec photo de profil)
                          FutureBuilder<UserModel?>(
                            future: _firebaseService.getUser(post.auteurUid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                UserModel user = snapshot.data!;
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: user.photoProfil != null
                                          ? NetworkImage(user.photoProfil!)
                                          : null,
                                      radius: 10,
                                      child: user.photoProfil == null
                                          ? const Icon(Icons.person, size: 20)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      user.nom,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const Text('Chargement...');
                            },
                          ),
                        ],
                      ),
                      // Extrait de la description avec ellipsis (...)
                      Text(
                        _getShortDescription(post.description),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black87,
                          fontFamily: "Questrial",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          // Tag du post
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: tagProperties['color'],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  tagProperties['icon'],
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  post.tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontFamily: "Questrial",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Upvotes
                          Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                color: post.upvotedBy.contains(
                                        _firebaseService.getCurrentUser()!.uid)
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text("${post.upvotes}"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.group.nom,
          style: const TextStyle(
            fontFamily: "Questrial",
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _postList.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun post disponible.",
                    style: TextStyle(
                      fontFamily: "Questrial",
                      color: AppColors.textDark,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _postList.length,
                  itemBuilder: (context, index) {
                    return _buildPostItem(_postList[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

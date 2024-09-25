import 'package:flutter/material.dart';
import 'package:nexus/models/group_model.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/screens/add_post_screen.dart';
import 'package:nexus/screens/post_detail_screen.dart';
import 'package:nexus/services/firebase_service.dart';

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
      // Rafraîchir les posts après ajout
      _loadPosts();
    }
  }

  Future<void> _deletePost(PostModel post) async {
    final confirmation = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmation de suppression"),
          content: const Text("Voulez-vous vraiment supprimer ce post ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await _firebaseService.deletePost(widget.group.id, post.id);
      // Rafraîchir les posts après suppression
      _loadPosts();
    }
  }

  // Gestion de l'overflow du texte avec des "..."
  String _getShortDescription(String description) {
    // Limite réduite pour compacter la description
    const int maxLength = 80;
    return description.length > maxLength
        ? '${description.substring(0, maxLength)}...'
        : description;
  }

  // Gestion de l'affichage des tags avec une couleur unique et une icône
  Map<String, dynamic> _getTagProperties(String tag) {
    switch (tag) {
      case 'WIS':
        return {'color': Colors.blueAccent, 'icon': Icons.school};
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
      onLongPress: isAuthor
          ? () => _deletePost(post) // Supprimer si l'utilisateur est l'auteur
          : null,
      onTap: () => _navigateToPostDetail(post),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              // Image à gauche, fixe en largeur et hauteur ajustée
              if (post.imageUrl.isNotEmpty)
                SizedBox(
                  height: 150,
                  width: 90,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      post.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Titre du post
                      Text(
                        post.titre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
                      const SizedBox(height: 4),
                      // Extrait de la description avec "..."
                      Text(
                        _getShortDescription(post.description),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Tag du post avec couleur et icône basé sur le tag du post
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
                                  post.tag, // Utilisation du tag du post
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
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
                                    ? Colors.blueAccent
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
      appBar: AppBar(
        title: Text(widget.group.nom),
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _postList.isEmpty
              ? const Center(child: Text("Aucun post disponible."))
              : ListView.builder(
                  itemCount: _postList.length,
                  itemBuilder: (context, index) {
                    return _buildPostItem(_postList[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        child: const Icon(Icons.add),
      ),
    );
  }
}

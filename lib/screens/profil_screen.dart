import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:nexus/themes/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  ProfilScreenState createState() => ProfilScreenState();
}

class ProfilScreenState extends State<ProfilScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<UserModel?> _userFuture;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<UserModel?> _fetchUserData() async {
    if (user == null) return null;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('utilisateurs')
        .doc(user!.uid)
        .get();
    if (doc.exists) {
      return UserModel.fromDocument(doc);
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || user == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');

      // Supprime l'ancienne image si il y en a une
      UserModel? userData = await _fetchUserData();
      if (userData?.photoProfil != null) {
        try {
          final oldRef =
              FirebaseStorage.instance.refFromURL(userData!.photoProfil!);
          await oldRef.delete();
        } catch (e) {
          throw ();
        }
      }

      await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();

      // Met à jour firestore avec la bonne URL
      await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(user!.uid)
          .update({
        'photoProfil': url,
      });

      setState(() {
        _userFuture = _fetchUserData(); // Refresh les données
      });
    } catch (e) {
      throw ();
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _editProfile(UserModel userData) async {
    // Naviguer vers l'écran d'édition du profil
    final updatedUser =
        await Navigator.pushNamed(context, '/editProfile', arguments: userData);
    if (updatedUser != null) {
      setState(() {
        _userFuture = _fetchUserData();
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth');
  }

  // Widget pour la section d'informations
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontFamily: "Questrial",
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.backgroundLight,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  // Widget pour une ligne d'information
  Widget _buildInfoRow(IconData icon, String title, String content) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.secondary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
          fontFamily: "Questrial",
        ),
      ),
      subtitle: Text(
        content,
        style: TextStyle(
          color: Colors.grey[600],
          fontFamily: "Questrial",
        ),
      ),
    );
  }

  // Widget pour une ligne de statistique
  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Utilisateur non connecté',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontFamily: "Questrial",
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text(
                'Erreur lors de la récupération des données',
                style: TextStyle(
                  fontFamily: "Questrial",
                ),
              ),
            );
          }

          final userData = snapshot.data!;

          // Obtenir la date du jour
          final String currentDate =
              DateFormat.yMMMMEEEEd('fr_FR').format(DateTime.now());

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                // Avatar de l'utilisateur avec possibilité de modifier la photo
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60.0,
                      backgroundColor: AppColors.primary,
                      backgroundImage: userData.photoProfil != null
                          ? CachedNetworkImageProvider(userData.photoProfil!)
                          : null,
                      child: userData.photoProfil == null
                          ? const Icon(
                              Icons.person,
                              size: 60.0,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (_isUploading)
                      const Positioned(
                        bottom: 10,
                        right: 10,
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Nom de l'utilisateur
                Text(
                  userData.nom,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: "Questrial",
                  ),
                ),
                const SizedBox(height: 4.0),
                // Email de l'utilisateur
                Text(
                  userData.email,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                    fontFamily: "Questrial",
                  ),
                ),
                const SizedBox(height: 16.0),
                // Bouton pour éditer le profil
                ElevatedButton(
                  onPressed: () => _editProfile(userData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Modifier le profil',
                    style: TextStyle(
                      fontFamily: "Questrial",
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                // Informations supplémentaires
                _buildInfoSection('Informations', [
                  _buildInfoRow(Icons.security_outlined, 'Rôle', userData.role),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date d\'inscription',
                    DateFormat.yMMMMd('fr_FR').format(userData.dateInscription),
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date du jour',
                    currentDate,
                  ),
                ]),
                const SizedBox(height: 24.0),
                // Statistiques ou autres fonctionnalités
                _buildInfoSection('Statistiques', [
                  _buildStatRow(
                      'Articles publiés', userData.nombreDePosts.toString()),
                  _buildStatRow('Nombre de upvotes',
                      userData.nombreDeUpvotesRecus.toString()),
                  _buildStatRow(
                      'Commentaires', userData.nombreDeCommentaires.toString()),
                ]),
                const SizedBox(height: 40),
                // Bouton de déconnexion
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Réduction de l'arrondi à 8
                      ),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Déconnexion',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Questrial",
                        color: AppColors.backgroundLight,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

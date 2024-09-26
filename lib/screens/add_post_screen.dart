import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';

class AddPostScreen extends StatefulWidget {
  final String groupId;

  const AddPostScreen({super.key, required this.groupId});

  @override
  AddPostScreenState createState() => AddPostScreenState();
}

class AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  String _postTitle = '';
  String _postDescription = '';
  File? _imageFile;
  String _selectedTag = 'Autre';
  bool _isLoading = false;

  // Liste des tags disponibles avec couleurs associées
  final List<Map<String, dynamic>> _tags = [
    {'tag': 'WIS', 'color': Colors.purple, 'icon': Icons.school},
    {'tag': 'DEVOPS', 'color': Colors.blueAccent, 'icon': Icons.build},
    {'tag': 'SYSOPS', 'color': Colors.teal, 'icon': Icons.computer},
    {'tag': 'IA', 'color': Colors.deepPurple, 'icon': Icons.memory},
    {'tag': 'Aide', 'color': Colors.orange, 'icon': Icons.help_outline},
    {'tag': 'Général', 'color': Colors.green, 'icon': Icons.forum},
    {'tag': 'Autre', 'color': Colors.grey, 'icon': Icons.tag},
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        String imageUrl = '';
        if (_imageFile != null) {
          imageUrl = await _firebaseService.uploadImage(_imageFile!);
        }

        UserModel? currentUser = await _firebaseService.getCurrentUserDetails();
        if (currentUser != null) {
          PostModel post = PostModel(
            id: '',
            titre: _postTitle,
            description: _postDescription,
            imageUrl: imageUrl,
            upvotes: 0,
            upvotedBy: [],
            dateCreation: DateTime.now(),
            auteurUid: currentUser.uid,
            tag: _selectedTag,
          );

          await _firebaseService.addPost(widget.groupId, post);

          // Incrémenter le nombre de posts de l'utilisateur
          await _firebaseService.updateUserPostCount(currentUser.uid);

          if (mounted) {
            Navigator.pop(context, true); // Retourne à l'écran précédent
          }
        }
      } catch (e) {
        // Affichage d'une erreur s'il y en a
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Ajouter un post",
          style: TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ de saisie pour le titre du post
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Titre du post',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: const TextStyle(
                    fontFamily: 'Questrial',
                    color: Colors.grey,
                  ),
                ),
                onSaved: (value) {
                  _postTitle = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre pour le post';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Champ de saisie pour la description du post
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: const TextStyle(
                    fontFamily: 'Questrial',
                    color: Colors.grey,
                  ),
                ),
                onSaved: (value) {
                  _postDescription = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description pour le post';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              // Dropdown pour la sélection des tags
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Tag',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: const TextStyle(
                    fontFamily: 'Questrial',
                    color: Colors.grey,
                  ),
                ),
                value: _selectedTag,
                items: _tags.map((tagData) {
                  return DropdownMenuItem<String>(
                    value: tagData['tag'],
                    child: Row(
                      children: [
                        Icon(tagData['icon'], color: tagData['color']),
                        const SizedBox(width: 10),
                        Text(tagData['tag']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTag = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Image sélectionnée et possibilité de la supprimer
              _imageFile != null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _imageFile = null;
                            });
                          },
                        )
                      ],
                    )
                  : const Text(
                      'Aucune image sélectionnée',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Questrial',
                        color: AppColors.textDark,
                      ),
                    ),
              const SizedBox(height: 10),
              // Bouton pour choisir une image
              TextButton.icon(
                icon: const Icon(Icons.image, color: AppColors.primary),
                label: const Text(
                  'Choisir une image',
                  style: TextStyle(
                    fontFamily: 'Questrial',
                    color: AppColors.primary,
                  ),
                ),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              // Bouton d'envoi du post
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitPost,
                      icon: Icon(
                        Icons.send,
                        color: Colors.grey.shade100,
                      ),
                      label: Text(
                        'Publier le post',
                        style: TextStyle(color: Colors.grey.shade100),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

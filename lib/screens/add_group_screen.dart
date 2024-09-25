import 'package:flutter/material.dart';
import 'package:nexus/models/group_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart'; // Assurez-vous d'utiliser le fichier de couleurs global

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  AddGroupScreenState createState() => AddGroupScreenState();
}

class AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  String _groupName = '';
  String _groupDescription = '';
  bool _isLoading = false;

  Future<void> _submitGroup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        UserModel? currentUser = await _firebaseService.getCurrentUserDetails();
        if (currentUser != null && currentUser.role == 'staff') {
          GroupModel group = GroupModel(
            id: '',
            nom: _groupName,
            description: _groupDescription,
            adminUid: currentUser.uid,
          );

          await _firebaseService.addGroup(group);

          // Retourner un résultat à l'écran précédent
          if (mounted) {
            Navigator.pop(context,
                true); // Renvoie "true" pour indiquer qu'un groupe a été ajouté
          }
        }
      } catch (e) {
        throw ();
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
          "Ajouter un groupe",
          style: TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0, // Supprime l'ombre sous l'appbar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ pour le nom du groupe
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Nom du groupe',
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
                  _groupName = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour le groupe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Champ pour la description du groupe
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
                maxLines: 3, // Permettre plus de lignes pour la description
                onSaved: (value) {
                  _groupDescription = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description pour le groupe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Bouton de validation
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                      ),
                      child: const Text(
                        'Créer le groupe',
                        style: TextStyle(
                          fontFamily: 'Questrial',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

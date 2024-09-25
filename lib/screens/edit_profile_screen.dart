import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/themes/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.userData.nom;
    _email = widget.userData.email;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState!.save();
      try {
        final user = FirebaseAuth.instance.currentUser;

        // Mettre à jour l'email
        if (_email != widget.userData.email && _email != null) {
          await user!.verifyBeforeUpdateEmail(_email!);
        }

        // Mettre à jour le mot de passe si un nouveau est fourni
        if (_password != null && _password!.isNotEmpty) {
          await user!.updatePassword(_password!);
        }

        // Mettre à jour le nom dans Firestore
        await FirebaseFirestore.instance
            .collection('utilisateurs')
            .doc(user!.uid)
            .update({
          'nom': _name,
          'email': _email,
        });
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e'),
        ));
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
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
                onSaved: (value) {
                  _name = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) {
                  _email = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nouveau mot de passe'),
                obscureText: true,
                onSaved: (value) {
                  _password = value;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Enregistrer les modifications'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

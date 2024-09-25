import 'package:flutter/material.dart';
import 'package:nexus/models/group_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/services/firebase_service.dart';

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
      appBar: AppBar(
        title: const Text("Ajouter un groupe"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom du groupe'),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
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
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitGroup,
                      child: const Text('Créer le groupe'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

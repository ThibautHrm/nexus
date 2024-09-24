import 'package:flutter/material.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/services/firebase_service.dart';

class CreateSignalementScreen extends StatefulWidget {
  const CreateSignalementScreen({super.key});

  @override
  CreateSignalementScreenState createState() => CreateSignalementScreenState();
}

class CreateSignalementScreenState extends State<CreateSignalementScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String titre = '';
  String description = '';
  String categorie = '';
  String? emplacement;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      var user = _firebaseService.getCurrentUser();
      if (user != null) {
        var currentUser = await _firebaseService.getUser(user.uid);
        if (currentUser != null) {
          SignalementModel signalement = SignalementModel(
            id: '', // L'ID sera généré par Firestore
            titre: titre,
            description: description,
            categorie: categorie,
            auteurId: currentUser.uid,
            auteurNom: currentUser.nom, // Si vous avez ajouté ce champ
            dateCreation: DateTime.now(),
            statut: 'En attente',
            emplacement: emplacement,
          );

          await _firebaseService.addSignalement(signalement);
          if (!mounted) return;
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un signalement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titre'),
                onSaved: (value) => titre = value!.trim(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
                onSaved: (value) => description = value!.trim(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Catégorie'),
                onSaved: (value) => categorie = value!.trim(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une catégorie.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Emplacement (optionnel)'),
                onSaved: (value) => emplacement = value?.trim(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
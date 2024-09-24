import 'package:flutter/material.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/services/firebase_service.dart';

class EditSignalementScreen extends StatefulWidget {
  final SignalementModel signalement;

  const EditSignalementScreen({super.key, required this.signalement});

  @override
  EditSignalementScreenState createState() => EditSignalementScreenState();
}

class EditSignalementScreenState extends State<EditSignalementScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late String titre;
  late String description;
  late String categorie;
  String? emplacement;

  @override
  void initState() {
    super.initState();
    titre = widget.signalement.titre;
    description = widget.signalement.description;
    categorie = widget.signalement.categorie;
    emplacement = widget.signalement.emplacement;
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      widget.signalement.titre = titre;
      widget.signalement.description = description;
      widget.signalement.categorie = categorie;
      widget.signalement.emplacement = emplacement;

      await _firebaseService.updateSignalement(widget.signalement);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le signalement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: titre,
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
                initialValue: description,
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
                initialValue: categorie,
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
                initialValue: emplacement,
                decoration:
                    const InputDecoration(labelText: 'Emplacement (optionnel)'),
                onSaved: (value) => emplacement = value?.trim(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
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
  String? categorie;
  String? emplacement;

  final List<String> _categories = [
    'Infrastructure',
    'Harcèlement',
    'Sécurité',
    'Maintenance',
    'Autre',
  ];

  final List<String> _campus = [
    'Angers',
    'Arras',
    'Auxerre',
    'Bordeaux',
    'Chartres',
    'Grenoble',
    'Lille',
    'Lyon',
    'Montpellier',
    'Nantes',
    'Paris',
    'Reims',
    'Rennes',
    'Saint-Étienne',
    'Toulouse',
  ];

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
            categorie: categorie ?? 'Autre',
            auteurId: currentUser.uid,
            auteurNom: currentUser.nom,
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
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  prefixIcon: Icon(Icons.title),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
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
              // Dropdown pour la catégorie
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    categorie = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une catégorie.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown pour l'emplacement (campus)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Emplacement',
                  prefixIcon: Icon(Icons.pin_drop_sharp),
                ),
                items: _campus
                    .map((campus) => DropdownMenuItem(
                          value: campus,
                          child: Text(campus),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    emplacement = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un emplacement.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Soumettre'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

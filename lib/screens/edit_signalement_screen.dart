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
  String? categorie;
  String? campus;
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

  @override
  void initState() {
    super.initState();
    titre = widget.signalement.titre;
    description = widget.signalement.description;
    categorie = widget.signalement.categorie;
    emplacement = widget.signalement.emplacement;

    // Vérifie que la catégorie est dans la liste
    if (!_categories.contains(categorie)) {
      categorie = null;
    }

    // Vérifie que l'emplacement est dans la liste
    if (!_campus.contains(emplacement)) {
      emplacement = null;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      widget.signalement.titre = titre;
      widget.signalement.description = description;
      widget.signalement.categorie = categorie ?? 'Autre';
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
                initialValue: description,
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
              DropdownButtonFormField<String>(
                value: categorie,
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
              DropdownButtonFormField<String>(
                value: emplacement,
                decoration: const InputDecoration(
                  labelText: 'Emplacement',
                  prefixIcon: Icon(Icons.location_on),
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
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer les modifications'),
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

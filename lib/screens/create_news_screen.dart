// lib/screens/add_news_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/models/news_model.dart';
import 'package:nexus/services/firebase_service.dart';

class AddNewsScreen extends StatefulWidget {
  const AddNewsScreen({super.key});

  @override
  AddNewsScreenState createState() => AddNewsScreenState();
}

class AddNewsScreenState extends State<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String _titre = '';
  String _description = '';
  String? _selectedEmplacement;
  File? _imageFile;

  // Liste des villes directement définie dans le fichier
  final List<String> _villes = [
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
    _selectedEmplacement = _villes.first;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _submitNews() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Vérifie que l'emplacement est sélectionné
      if (_selectedEmplacement == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un emplacement')),
        );
        return;
      }

      // Upload de l'image
      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await _firebaseService.uploadImage(_imageFile!);
      }

      // Création de l'objet NewsModel
      NewsModel news = NewsModel(
        id: '',
        titre: _titre,
        description: _description,
        imageUrl: imageUrl,
        emplacement: _selectedEmplacement!,
        dateCreation: DateTime.now(),
      );

      // Ajout de la news dans Firestore
      await _firebaseService.addNews(news);

      // Retour à la page précédente
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // Widget pour le champ de sélection de l'emplacement
  Widget _buildEmplacementDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Emplacement'),
      value: _selectedEmplacement,
      items: _villes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedEmplacement = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner un emplacement';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une news'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un titre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _titre = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 16.0),
              _buildEmplacementDropdown(),
              const SizedBox(height: 16.0),
              _imageFile != null
                  ? Image.file(_imageFile!)
                  : const Text('Aucune image sélectionnée'),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Choisir une image'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitNews,
                child: const Text('Publier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

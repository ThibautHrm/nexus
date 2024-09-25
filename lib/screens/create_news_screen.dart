import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/models/news_model.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';

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
      if (_selectedEmplacement == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un emplacement')),
        );
        return;
      }

      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await _firebaseService.uploadImage(_imageFile!);
      }

      NewsModel news = NewsModel(
        id: '',
        titre: _titre,
        description: _description,
        imageUrl: imageUrl,
        emplacement: _selectedEmplacement!,
        dateCreation: DateTime.now(),
      );

      await _firebaseService.addNews(news);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Widget _buildSimpleTextField(String labelText, Function(String) onSaved,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontFamily: 'Questrial',
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSaved: (value) => onSaved(value!),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            labelText: 'Emplacement',
            labelStyle: const TextStyle(
              fontFamily: 'Questrial',
              color: AppColors.textDark,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          value: _selectedEmplacement,
          items: _villes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child:
                  Text(value, style: const TextStyle(fontFamily: 'Questrial')),
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
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Aucune image sélectionnée',
                    style: TextStyle(
                      fontFamily: 'Questrial',
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 10),
        TextButton.icon(
          icon: const Icon(Icons.image, color: AppColors.secondary),
          label: const Text(
            'Choisir une image',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: AppColors.secondary,
            ),
          ),
          onPressed: _pickImage,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une news',
          style: TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSimpleTextField(
                'Titre',
                (value) => _titre = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un titre';
                  }
                  return null;
                },
              ),
              _buildSimpleTextField(
                'Description',
                (value) => _description = value,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  return null;
                },
              ),
              _buildDropdown(),
              const SizedBox(height: 16.0),
              _buildImagePicker(),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitNews,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Publier',
                  style: TextStyle(
                    fontFamily: 'Questrial',
                    fontSize: 16,
                    color: Colors.white,
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

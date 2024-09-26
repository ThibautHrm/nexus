import 'package:flutter/material.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';

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

    if (!_categories.contains(categorie)) {
      categorie = null;
    }

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

  Widget _buildSimpleTextField(String labelText, IconData icon,
      {int maxLines = 1,
      required Function(String) onSaved,
      String? initialValue,
      String? Function(String?)? validator}) {
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
          initialValue: initialValue,
          style: const TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              fontFamily: 'Questrial',
              fontSize: 16,
              color: AppColors.textDark,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: Icon(icon, color: AppColors.secondary),
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

  Widget _buildDropdown(String labelText, IconData icon, List<String> items,
      {required String? value,
      required Function(String?) onChanged,
      String? Function(String?)? validator}) {
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
            labelText: labelText,
            labelStyle: const TextStyle(
              fontFamily: 'Questrial',
              color: AppColors.textDark,
              fontSize: 16,
            ),
            prefixIcon: Icon(icon, color: AppColors.secondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          value: value,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Questrial',
                        color: AppColors.textDark,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Modifier le signalement',
          style: TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSimpleTextField(
                'Titre',
                Icons.title,
                initialValue: titre,
                onSaved: (value) => titre = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre.';
                  }
                  return null;
                },
              ),
              _buildSimpleTextField(
                'Description',
                Icons.description,
                maxLines: 5,
                initialValue: description,
                onSaved: (value) => description = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description.';
                  }
                  return null;
                },
              ),
              _buildDropdown(
                'Catégorie',
                Icons.category,
                _categories,
                value: categorie,
                onChanged: (value) => setState(() => categorie = value),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une catégorie.';
                  }
                  return null;
                },
              ),
              _buildDropdown(
                'Emplacement',
                Icons.pin_drop,
                _campus,
                value: emplacement,
                onChanged: (value) => setState(() => emplacement = value),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un emplacement.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enregistrer les modifications',
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

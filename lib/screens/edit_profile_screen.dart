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
  String? _oldPassword;
  String? _newPassword;
  String? _confirmPassword;
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _name = widget.userData.nom;
    _email = widget.userData.email;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Sauvegarde les champs de texte
      _formKey.currentState!.save();

      // Validation des mots de passe
      if (_newPassword != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Les nouveaux mots de passe ne correspondent pas.'),
        ));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;

        //! Vérifier l'ancien mot de passe (à fix)
        if (_oldPassword != null && _oldPassword!.isNotEmpty) {
          final credential = EmailAuthProvider.credential(
              email: user!.email!, password: _oldPassword!);
          await user.reauthenticateWithCredential(credential);
        }

        // Mettre à jour l'email
        if (_email != widget.userData.email && _email != null) {
          await user!.verifyBeforeUpdateEmail(_email!);
        }

        // Mettre à jour le mot de passe si un nouveau est fourni
        if (_newPassword != null && _newPassword!.isNotEmpty) {
          await user!.updatePassword(_newPassword!);
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

  Widget _buildSimpleTextField(String labelText, Function(String) onSaved,
      {bool obscureText = false,
      bool isPasswordField = false,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      Function? onToggleVisibility,
      bool obscure = true}) {
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
          obscureText: obscureText,
          style: const TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              fontFamily: 'Questrial',
              fontSize: 16,
              color: AppColors.textDark,
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
            suffixIcon: isPasswordField
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.secondary,
                    ),
                    onPressed: () {
                      if (onToggleVisibility != null) {
                        onToggleVisibility();
                      }
                    },
                  )
                : null,
          ),
          onSaved: (value) => onSaved(value!),
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
          'Modifier le profil',
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
                'Nom',
                (value) => _name = value,
              ),
              _buildSimpleTextField(
                'Email',
                (value) => _email = value,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildSimpleTextField(
                'Ancien mot de passe',
                (value) => _oldPassword = value,
                obscureText: _obscureOldPassword,
                isPasswordField: true,
                onToggleVisibility: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
              ),
              _buildSimpleTextField(
                'Nouveau mot de passe',
                (value) => _newPassword = value,
                obscureText: _obscureNewPassword,
                isPasswordField: true,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              _buildSimpleTextField(
                'Confirmer le nouveau mot de passe',
                (value) => _confirmPassword = value,
                obscureText: _obscureConfirmPassword,
                isPasswordField: true,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateProfile,
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

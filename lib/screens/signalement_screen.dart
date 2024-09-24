import 'package:flutter/material.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/screens/create_signalement_screen.dart';
import 'package:nexus/screens/edit_signalement_screen.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/widgets/modal_widget.dart';

class SignalementScreen extends StatefulWidget {
  const SignalementScreen({super.key});

  @override
  SignalementScreenState createState() => SignalementScreenState();
}

class SignalementScreenState extends State<SignalementScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  List<SignalementModel> _signalements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSignalements();
  }

  Future<void> _loadSignalements() async {
    setState(() {
      _isLoading = true;
    });

    // Récupérer l'utilisateur actuel
    var user = _firebaseService.getCurrentUser();
    if (user != null) {
      _currentUser = await _firebaseService.getUser(user.uid);

      if (_currentUser != null) {
        // Récupérer les signalements en fonction du rôle
        if (_currentUser!.role == 'staff') {
          _signalements = await _firebaseService.getAllSignalements();
        } else {
          _signalements =
              await _firebaseService.getSignalementsByUser(user.uid);
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSignalementDetails(SignalementModel signalement) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SignalementDetailsModal(
          signalement: signalement,
          isEditable: _currentUser?.uid == signalement.auteurId,
          onDelete: () {
            _deleteSignalement(signalement.id);
          },
          onEdit: () {
            _editSignalement(signalement);
          },
        );
      },
    );
  }

  Future<void> _deleteSignalement(String id) async {
    await _firebaseService.deleteSignalement(id);
    _loadSignalements();
  }

  void _editSignalement(SignalementModel signalement) {
    // Naviguer vers une page d'édition du signalement
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSignalementScreen(signalement: signalement),
      ),
    ).then((_) {
      _loadSignalements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signalements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _signalements.isEmpty
              ? const Center(child: Text('Aucun signalement disponible.'))
              : ListView.builder(
                  itemCount: _signalements.length,
                  itemBuilder: (context, index) {
                    final signalement = _signalements[index];
                    return ListTile(
                      title: Text(signalement.titre),
                      subtitle: Text('Catégorie: ${signalement.categorie}'),
                      trailing: Text(signalement.statut),
                      onTap: () => _showSignalementDetails(signalement),
                    );
                  },
                ),
      floatingActionButton: _currentUser?.role != 'staff'
          ? FloatingActionButton(
              onPressed: () {
                // Naviguer vers la page de création de signalement
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSignalementScreen(),
                  ),
                ).then((_) {
                  _loadSignalements();
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

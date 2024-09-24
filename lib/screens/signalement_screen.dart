import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      isScrollControlled: true,
      builder: (context) {
        return SignalementDetailsModal(
          signalement: signalement,
          isEditable: _currentUser?.uid == signalement.auteurId,
          isStaff: _currentUser?.role == 'staff',
          onDelete: () {
            _deleteSignalement(signalement.id);
            Navigator.pop(context);
          },
          onEdit: () {
            _editSignalement(signalement);
          },
        );
      },
    ).then((_) {
      _loadSignalements();
    });
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

  IconData _getCategorieIcon(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'infrastructure':
        return Icons.business;
      case 'sécurité':
        return Icons.security;
      case 'maintenance':
        return Icons.build;
      case 'harcèlement':
        return Icons.report_gmailerrorred;
      case 'autre':
        return Icons.help_outline;
      default:
        return Icons.report_problem;
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en attente':
        return Colors.orange;
      case 'en cours':
        return Colors.blue;
      case 'résolu':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          _getCategorieIcon(signalement.categorie),
                          color: Theme.of(context).primaryColor,
                          size: 40,
                        ),
                        title: Text(
                          signalement.titre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'Catégorie: ${signalement.categorie}\nDate: ${_formatDate(signalement.dateCreation)}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatutColor(signalement.statut),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            signalement.statut,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () => _showSignalementDetails(signalement),
                      ),
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

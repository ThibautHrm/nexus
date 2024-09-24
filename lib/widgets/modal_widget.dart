import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/services/firebase_service.dart';

class SignalementDetailsModal extends StatefulWidget {
  final SignalementModel signalement;
  final bool isEditable;
  final bool isStaff;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SignalementDetailsModal({
    super.key,
    required this.signalement,
    required this.isEditable,
    required this.isStaff,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  SignalementDetailsModalState createState() => SignalementDetailsModalState();
}

class SignalementDetailsModalState extends State<SignalementDetailsModal> {
  late String statut;
  final FirebaseService _firebaseService = FirebaseService();

  final List<String> _statuts = [
    'En attente',
    'En cours',
    'Résolu',
  ];

  @override
  void initState() {
    super.initState();
    statut = widget.signalement.statut;
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

  // Pour mettre à jour le statut du signalement
  Future<void> _updateStatut(String newStatut) async {
    setState(() {
      statut = newStatut;
    });
    widget.signalement.statut = newStatut;
    await _firebaseService.updateSignalementStatut(
        widget.signalement.id, newStatut);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Icon(
                      _getCategorieIcon(widget.signalement.categorie),
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      widget.signalement.titre,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatutColor(statut),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statut,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.isStaff) ...[
                    DropdownButtonFormField<String>(
                      value: statut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        prefixIcon: Icon(Icons.assignment_turned_in),
                      ),
                      items: _statuts
                          .map((stat) => DropdownMenuItem(
                                value: stat,
                                child: Text(stat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _updateStatut(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  Divider(color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Catégorie'),
                    subtitle: Text(widget.signalement.categorie),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Description'),
                    subtitle: Text(widget.signalement.description),
                  ),
                  if (widget.signalement.emplacement != null)
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Emplacement'),
                      subtitle: Text(widget.signalement.emplacement!),
                    ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date de création'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(widget.signalement.dateCreation),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.isEditable || widget.isStaff)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.isEditable)
                          ElevatedButton.icon(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier'),
                          ),
                        ElevatedButton.icon(
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete),
                          label: const Text('Supprimer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

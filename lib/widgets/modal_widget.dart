import 'package:flutter/material.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:intl/intl.dart';

class SignalementDetailsModal extends StatelessWidget {
  final SignalementModel signalement;
  final bool isEditable;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SignalementDetailsModal({
    super.key,
    required this.signalement,
    required this.isEditable,
    required this.onDelete,
    required this.onEdit,
  });

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
                      _getCategorieIcon(signalement.categorie),
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      signalement.titre,
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
                        color: _getStatutColor(signalement.statut),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        signalement.statut,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Catégorie'),
                    subtitle: Text(signalement.categorie),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Description'),
                    subtitle: Text(signalement.description),
                  ),
                  if (signalement.emplacement != null)
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Emplacement'),
                      subtitle: Text(signalement.emplacement!),
                    ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date de création'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(signalement.dateCreation),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isEditable)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier'),
                        ),
                        ElevatedButton.icon(
                          onPressed: onDelete,
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

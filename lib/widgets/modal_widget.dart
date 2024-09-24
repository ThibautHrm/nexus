import 'package:flutter/material.dart';
import 'package:nexus/models/signalement_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          Text(
            signalement.titre,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Catégorie: ${signalement.categorie}'),
          const SizedBox(height: 8),
          Text('Statut: ${signalement.statut}'),
          const SizedBox(height: 8),
          Text('Description:\n${signalement.description}'),
          const SizedBox(height: 8),
          if (signalement.emplacement != null)
            Text('Emplacement: ${signalement.emplacement}'),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String id;
  String nom;
  String description;
  String adminUid; // UID du créateur du groupe (staff)
  List<String> membres; // Liste des membres (UID des utilisateurs)
  List<String> demandesEnAttente; // UID des utilisateurs qui ont demandé à rejoindre

  GroupModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.adminUid,
    this.membres = const [],
    this.demandesEnAttente = const [],
  });

  // Convertit un document Firestore en GroupModel
  factory GroupModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      nom: data['nom'],
      description: data['description'],
      adminUid: data['adminUid'],
      membres: List<String>.from(data['membres'] ?? []),
      demandesEnAttente: List<String>.from(data['demandesEnAttente'] ?? []),
    );
  }

  // Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'adminUid': adminUid,
      'membres': membres,
      'demandesEnAttente': demandesEnAttente,
    };
  }
}
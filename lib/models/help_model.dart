import 'package:cloud_firestore/cloud_firestore.dart';

class HelpModel {
  String id;
  String titre;
  String description;
  String sujet;
  String auteurId;
  DateTime dateCreation;
  int upvotes;
  List<String> upvotedBy;
  String statut;

  HelpModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.sujet,
    required this.auteurId,
    required this.dateCreation,
    this.upvotes = 0,
    List<String>? upvotedBy,
    this.statut = 'Ouvert',
  }) : upvotedBy = upvotedBy ?? [];

  // Convertit l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'sujet': sujet,
      'auteurId': auteurId,
      'dateCreation': dateCreation,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'statut': statut,
    };
  }

  // Crée un objet HelpModel à partir d'un Document Firebase
  factory HelpModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HelpModel(
      id: data['id'],
      titre: data['titre'],
      description: data['description'],
      sujet: data['sujet'],
      auteurId: data['auteurId'],
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
      statut: data['statut'] ?? 'Ouvert',
    );
  }
}
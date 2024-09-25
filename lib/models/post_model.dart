import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String id;
  String titre;
  String description;
  String imageUrl;
  String auteurUid; // UID de l'utilisateur qui a posté
  int upvotes;
  DateTime dateCreation;
  List<String> upvotedBy; // UID des utilisateurs qui ont voté
  String tag; // Tag pour le post

  PostModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.imageUrl,
    required this.auteurUid,
    required this.dateCreation,
    this.upvotes = 0,
    this.upvotedBy = const [],
    required this.tag, // Nouveau champ
  });

  // Convertit un document Firestore en PostModel
  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      titre: data['titre'],
      description: data['description'],
      imageUrl: data['imageUrl'] ?? '',
      auteurUid: data['auteurUid'],
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
      tag: data['tag'] ?? 'Autre', // Ajout du tag avec valeur par défaut
    );
  }

  // Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'imageUrl': imageUrl,
      'auteurUid': auteurUid,
      'dateCreation': dateCreation,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'tag': tag, // Ajout du tag
    };
  }
}

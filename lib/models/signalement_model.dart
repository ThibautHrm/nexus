import 'package:cloud_firestore/cloud_firestore.dart';

class SignalementModel {
  String id;
  String titre;
  String description;
  String categorie;
  String auteurId;
  String auteurNom;
  DateTime dateCreation;
  String statut;
  String? emplacement;
  List<String>? images;

  SignalementModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.auteurId,
    required this.auteurNom,
    required this.dateCreation,
    this.statut = 'En attente',
    this.emplacement,
    this.images,
  });

  // Convertit l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'categorie': categorie,
      'auteurId': auteurId,
      'auteurNom': auteurNom,
      'dateCreation': dateCreation,
      'statut': statut,
      'emplacement': emplacement,
      'images': images,
    };
  }

  // Crée un objet SignalementModel à partir d'un Document Firebase
  factory SignalementModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SignalementModel(
      id: data['id'],
      titre: data['titre'],
      description: data['description'],
      categorie: data['categorie'],
      auteurId: data['auteurId'],
      auteurNom: data['auteurNom'],
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      statut: data['statut'] ?? 'En attente',
      emplacement: data['emplacement'],
      images: List<String>.from(data['images'] ?? []),
    );
  }
}

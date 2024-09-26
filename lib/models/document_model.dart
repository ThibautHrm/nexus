import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  String id;
  String nom;
  String url;
  String ownerId;
  DateTime dateAjout;

  DocumentModel({
    required this.id,
    required this.nom,
    required this.url,
    required this.ownerId,
    required this.dateAjout,
  });

  // Méthode pour convertir en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'url': url,
      'ownerId': ownerId,
      'dateAjout': dateAjout,
    };
  }

  // Méthode pour créer un DocumentModel à partir d'une Map (Firestore)
  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      nom: map['nom'] ?? '',
      url: map['url'] ?? '',
      ownerId: map['ownerId'] ?? '',
      dateAjout: (map['dateAjout'] as Timestamp).toDate(),
    );
  }
}

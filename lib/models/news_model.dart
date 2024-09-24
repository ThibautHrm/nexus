import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  String id;
  String titre;
  String description;
  String imageUrl;
  String emplacement;
  DateTime dateCreation;

  NewsModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.imageUrl,
    required this.emplacement,
    required this.dateCreation,
  });

  // Convertir un document Firestore en NewsModel
  factory NewsModel.fromDocument(DocumentSnapshot doc) {
    return NewsModel(
      id: doc.id,
      titre: doc['titre'],
      description: doc['description'],
      imageUrl: doc['imageUrl'],
      emplacement: doc['emplacement'],
      dateCreation: (doc['dateCreation'] as Timestamp).toDate(),
    );
  }

  // Convertir NewsModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'imageUrl': imageUrl,
      'emplacement': emplacement,
      'dateCreation': dateCreation,
    };
  }
}

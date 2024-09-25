import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String id;
  String contenu;
  String auteurUid;
  DateTime dateCreation;
  int upvotes;
  List<String> upvotedBy;

  CommentModel({
    required this.id,
    required this.contenu,
    required this.auteurUid,
    required this.dateCreation,
    this.upvotes = 0, // Initialement 0 upvotes
    this.upvotedBy = const [], // Initialement personne n'a upvoté
  });

  // Convertit un document Firestore en CommentModel
  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Le document est vide ou mal formé.');
    }

    return CommentModel(
      id: doc.id,
      contenu: data['contenu'] ?? '',
      auteurUid: data['auteurUid'] ?? '',
      dateCreation:
          (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      upvotes: data['upvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
    );
  }

  // Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'contenu': contenu,
      'auteurUid': auteurUid,
      'dateCreation': dateCreation,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
    };
  }
}

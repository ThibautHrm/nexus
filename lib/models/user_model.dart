import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String nom;
  String email;
  DateTime dateInscription;
  String? photoProfil;
  String role;
  int nombreDePosts;
  int nombreDeUpvotesRecus;
  int nombreDeCommentaires;

  UserModel({
    required this.uid,
    required this.nom,
    required this.email,
    required this.dateInscription,
    this.photoProfil,
    this.role = 'étudiant',
    this.nombreDePosts = 0,
    this.nombreDeUpvotesRecus = 0,
    this.nombreDeCommentaires = 0,
  });

  // Convertit l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nom': nom,
      'email': email,
      'dateInscription': dateInscription,
      'photoProfil': photoProfil,
      'role': role,
      'nombreDePosts': nombreDePosts,
      'nombreDeUpvotesRecus': nombreDeUpvotesRecus,
      'nombreDeCommentaires': nombreDeCommentaires,
    };
  }

  // Crée un objet UserModel à partir d'un Document Firebase
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      nom: data['nom'],
      email: data['email'],
      dateInscription: (data['dateInscription'] as Timestamp).toDate(),
      photoProfil: data['photoProfil'],
      role: data['role'] ?? 'étudiant',
      nombreDePosts: data['nombreDePosts'] ?? 0,
      nombreDeUpvotesRecus: data['nombreDeUpvotesRecus'] ?? 0,
      nombreDeCommentaires: data['nombreDeCommentaires'] ?? 0,
    );
  }
}

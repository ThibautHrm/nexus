import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String nom;
  String email;
  DateTime dateInscription;
  String? photoProfil;
  String role;

  UserModel({
    required this.uid,
    required this.nom,
    required this.email,
    required this.dateInscription,
    this.photoProfil,
    this.role = 'étudiant',
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
    );
  }
}

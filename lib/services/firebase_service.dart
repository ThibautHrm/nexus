import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/models/help_model.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/models/user_model.dart';

class FirebaseService {
  // Paterne en Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Récupère l'instance de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupération de l'état de connexion
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Gestion de l'authentification
  Future<User?> signUp(String email, String password, String nom) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Créer un nouvel utilisateur dans Firestore
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        nom: nom,
        email: email,
        dateInscription: DateTime.now(),
      );
      await addUser(user);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Connexion d'un utilisateur
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Déconnexion de l'utilisateur
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Verification de l'utilisateur
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Gestion des utilisateurs
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('utilisateurs').doc(user.uid).set(user.toMap());
  }

  // Récuperer un utilisateur
  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('utilisateurs').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromDocument(doc);
    }
    return null;
  }

  // Mettre à jour l'utilisateur
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection('utilisateurs')
        .doc(user.uid)
        .update(user.toMap());
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('utilisateurs').doc(uid).delete();
  }

  // Gestion des demandes d'aide (HelpModel)
  Future<void> addHelp(HelpModel help) async {
    DocumentReference docRef = _firestore.collection('aides').doc();
    help.id = docRef.id;
    await docRef.set(help.toMap());
  }

  // Récupérer une demande d'aide
  Future<HelpModel?> getHelp(String id) async {
    DocumentSnapshot doc = await _firestore.collection('aides').doc(id).get();
    if (doc.exists) {
      return HelpModel.fromDocument(doc);
    }
    return null;
  }

  // Récupérer la liste des demandes d'aide
  Future<List<HelpModel>> getAllHelps() async {
    QuerySnapshot snapshot = await _firestore.collection('aides').get();
    return snapshot.docs.map((doc) => HelpModel.fromDocument(doc)).toList();
  }

  // Mettre à jour une demande d'aide
  Future<void> updateHelp(HelpModel help) async {
    await _firestore.collection('aides').doc(help.id).update(help.toMap());
  }

  // Supprime une demande d'aide
  Future<void> deleteHelp(String id) async {
    await _firestore.collection('aides').doc(id).delete();
  }

  // Mettre un upvote sur la demande d'aide
  Future<void> upvoteHelp(String helpId, String userId) async {
    DocumentReference docRef = _firestore.collection('aides').doc(helpId);
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      HelpModel help = HelpModel.fromDocument(doc);
      if (!help.upvotedBy.contains(userId)) {
        help.upvotedBy.add(userId);
        help.upvotes += 1;
        await docRef.update({
          'upvotedBy': help.upvotedBy,
          'upvotes': help.upvotes,
        });
      }
    }
  }

  // Gestion des signalements (SignalementModel)
  Future<void> addSignalement(SignalementModel signalement) async {
    DocumentReference docRef = _firestore.collection('signalements').doc();
    signalement.id = docRef.id;
    await docRef.set(signalement.toMap());
  }

  // Récupérer un signalement
  Future<SignalementModel?> getSignalement(String id) async {
    DocumentSnapshot doc =
        await _firestore.collection('signalements').doc(id).get();
    if (doc.exists) {
      return SignalementModel.fromDocument(doc);
    }
    return null;
  }

  // Mise à jour du statut d'un signalement
  Future<void> updateSignalementStatut(
      String signalementId, String newStatut) async {
    await _firestore.collection('signalements').doc(signalementId).update({
      'statut': newStatut,
    });
  }

  // Récupérer les signalements d'un utilisateurs
  Future<List<SignalementModel>> getSignalementsByUser(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('signalements')
        .where('auteurId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => SignalementModel.fromDocument(doc))
        .toList();
  }

  // Récuperer la liste des signalements
  Future<List<SignalementModel>> getAllSignalements() async {
    QuerySnapshot snapshot = await _firestore.collection('signalements').get();
    return snapshot.docs
        .map((doc) => SignalementModel.fromDocument(doc))
        .toList();
  }

  // Mettre à jour un signalement
  Future<void> updateSignalement(SignalementModel signalement) async {
    await _firestore
        .collection('signalements')
        .doc(signalement.id)
        .update(signalement.toMap());
  }

  // Supprimer un signalement
  Future<void> deleteSignalement(String id) async {
    await _firestore.collection('signalements').doc(id).delete();
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:nexus/models/comment_model.dart';
import 'package:nexus/models/document_model.dart';
import 'package:nexus/models/group_model.dart';
import 'package:nexus/models/help_model.dart';
import 'package:nexus/models/news_model.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:path/path.dart';

class FirebaseService {
  // Paterne en Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Récupère l'instance de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupération de l'état de connexion
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Création de l'authentification
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

  // Récupérer les détails de l'utilisateur actuel
  Future<UserModel?> getCurrentUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('utilisateurs').doc(user.uid).get();
      return UserModel.fromDocument(doc);
    }
    return null;
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

  // Création des signalements
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

  // Ajouter une news
  Future<void> addNews(NewsModel news) async {
    DocumentReference docRef = _firestore.collection('news').doc();
    news.id = docRef.id;
    await docRef.set(news.toMap());
  }

  // Récupérer une news par ID
  Future<NewsModel?> getNews(String id) async {
    DocumentSnapshot doc = await _firestore.collection('news').doc(id).get();
    if (doc.exists) {
      return NewsModel.fromDocument(doc);
    }
    return null;
  }

  // Récupérer toutes les news (avec option de filtrage par emplacement)
  Future<List<NewsModel>> getAllNews({String? emplacement}) async {
    Query query =
        _firestore.collection('news').orderBy('dateCreation', descending: true);
    if (emplacement != null && emplacement.isNotEmpty) {
      query = query.where('emplacement', isEqualTo: emplacement);
    }
    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) => NewsModel.fromDocument(doc)).toList();
  }

  // Mettre à jour une news
  Future<void> updateNews(NewsModel news) async {
    await _firestore.collection('news').doc(news.id).update(news.toMap());
  }

  // Récupère une news avec son id
  Future<NewsModel> getNewsById(String id) async {
    DocumentSnapshot doc = await _firestore.collection('news').doc(id).get();
    return NewsModel.fromDocument(doc);
  }

  // Supprimer une news
  Future<void> deleteNews(String id) async {
    await _firestore.collection('news').doc(id).delete();
  }

  // Upload de l'image dans Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    String fileName = basename(imageFile.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('news_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Récupérer tous les groupes
  Future<List<GroupModel>> getAllGroups() async {
    QuerySnapshot snapshot = await _firestore.collection('groups').get();
    return snapshot.docs.map((doc) => GroupModel.fromDocument(doc)).toList();
  }

  // Récupérer les posts d'un groupe
  Future<List<PostModel>> getPostsForGroup(String groupId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .get();
    return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
  }

  // Récupérer les commentaires pour un post
  Future<List<CommentModel>> getCommentsForPost(
      String groupId, String postId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    return snapshot.docs.map((doc) => CommentModel.fromDocument(doc)).toList();
  }

  // Créer un groupe
  Future<void> addGroup(GroupModel group) async {
    DocumentReference docRef = _firestore.collection('groups').doc();
    group.id = docRef.id;
    await docRef.set(group.toMap());
  }

  // Demander à rejoindre un groupe
  Future<void> requestToJoinGroup(String groupId, String userId) async {
    DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
    await groupRef.update({
      'demandesEnAttente': FieldValue.arrayUnion([userId]),
    });
  }

  // Accepter une adhésion à un groupe
  Future<void> acceptGroupRequest(String groupId, String userId) async {
    DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
    await groupRef.update({
      'demandesEnAttente': FieldValue.arrayRemove([userId]),
      'membres': FieldValue.arrayUnion([userId]),
    });
  }

  // Poster dans un groupe
  Future<void> addPost(String groupId, PostModel post) async {
    DocumentReference docRef =
        _firestore.collection('groups').doc(groupId).collection('posts').doc();
    post.id = docRef.id;
    await docRef.set(post.toMap());
  }

  // Mise à jour du nombre de posts de l'utilisateur
  Future<void> updateUserPostCount(String userId) async {
    DocumentReference userRef =
        _firestore.collection('utilisateurs').doc(userId);
    await userRef.update({
      'nombreDePosts': FieldValue.increment(1),
    });
  }

  // Supprimer un post dans un groupe
  Future<void> deletePost(String groupId, String postId) async {
    DocumentReference postRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId);

    await postRef.delete();
  }

  // Ajouter un commentaire dans un post et mettre à jour le nombre de commentaires de l'utilisateur
  Future<void> addCommentToPost(
      String groupId, String postId, CommentModel comment) async {
    DocumentReference docRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();
    comment.id = docRef.id;
    await docRef.set(comment.toMap());

    // Incrémenter le nombre de commentaires de l'utilisateur
    DocumentReference userRef =
        _firestore.collection('utilisateurs').doc(comment.auteurUid);
    await userRef.update({
      'nombreDeCommentaires': FieldValue.increment(1),
    });
  }

  // Supprimer un commentaire dans un post
  Future<void> deleteComment(
      String groupId, String postId, String commentId) async {
    DocumentReference commentRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    await commentRef.delete(); // Suppression du commentaire
  }

  // Décrémente le nombre de commentaires d'un utilisateur
  Future<void> decrementUserCommentCount(String userId) async {
    DocumentReference userRef =
        _firestore.collection('utilisateurs').doc(userId);
    await userRef.update({
      'nombreDeCommentaires': FieldValue.increment(-1),
    });
  }

// Upvote ou dé-upvote un commentaire
  Future<void> toggleUpvoteComment(
      String groupId, String postId, String commentId, String userId) async {
    try {
      debugPrint(
          'toggleUpvoteComment appelé avec groupId: $groupId, postId: $postId, commentId: $commentId, userId: $userId');

      // Chemin correct pour accéder au commentaire dans le groupe et le post
      DocumentReference commentRef = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      DocumentSnapshot doc = await commentRef.get();

      // Vérifie si le document existe et a des données valides
      if (!doc.exists || doc.data() == null) {
        throw Exception('Le commentaire avec ID $commentId n\'existe pas.');
      }

      CommentModel comment = CommentModel.fromDocument(doc);

      // Si l'utilisateur a déjà upvoté, on retire son upvote
      if (comment.upvotedBy.contains(userId)) {
        comment.upvotedBy.remove(userId);
        comment.upvotes -= 1;

        // Décrémente le nombre de upvotes reçus de l'auteur du commentaire
        DocumentReference userRef =
            _firestore.collection('utilisateurs').doc(comment.auteurUid);
        await userRef.update({
          'nombreDeUpvotesRecus': FieldValue.increment(-1),
        });
      } else {
        // Sinon, l'utilisateur ajoute un upvote
        comment.upvotedBy.add(userId);
        comment.upvotes += 1;

        // Incrémente le nombre de upvotes reçus de l'auteur du commentaire
        DocumentReference userRef =
            _firestore.collection('utilisateurs').doc(comment.auteurUid);
        await userRef.update({
          'nombreDeUpvotesRecus': FieldValue.increment(1),
        });
      }

      // Mise à jour du commentaire avec les nouvelles valeurs
      await commentRef.update({
        'upvotedBy': comment.upvotedBy,
        'upvotes': comment.upvotes,
      });
    } catch (e) {
      debugPrint('Erreur dans toggleUpvoteComment: $e');
    }
  }

  // Upvote ou dé-upvote un post
  Future<void> toggleUpvotePost(
      String groupId, String postId, String userId) async {
    DocumentReference postRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId);

    DocumentSnapshot doc = await postRef.get();
    PostModel post = PostModel.fromDocument(doc);

    if (post.upvotedBy.contains(userId)) {
      // Si l'utilisateur a déjà upvoté, on retire son upvote
      post.upvotedBy.remove(userId);
      post.upvotes -= 1;

      // Décrémente le nombre de upvotes reçus de l'auteur du post
      DocumentReference userRef =
          _firestore.collection('utilisateurs').doc(post.auteurUid);
      await userRef.update({
        'nombreDeUpvotesRecus': FieldValue.increment(-1),
      });
    } else {
      // Si l'utilisateur n'a pas encore upvoté, on ajoute son upvote
      post.upvotedBy.add(userId);
      post.upvotes += 1;

      // Incrémente le nombre de upvotes reçus de l'auteur du post
      DocumentReference userRef =
          _firestore.collection('utilisateurs').doc(post.auteurUid);
      await userRef.update({
        'nombreDeUpvotesRecus': FieldValue.increment(1),
      });
    }

    await postRef.update({
      'upvotedBy': post.upvotedBy,
      'upvotes': post.upvotes,
    });
  }

  // Supprimer un post et tous ses commentaires, ainsi que l'image associée dans Firebase Storage,
// et mettre à jour les statistiques de l'utilisateur
  Future<void> deletePostWithCommentsAndImage(
      String groupId, PostModel post) async {
    try {
      // Récupérer les détails de l'utilisateur qui a créé le post
      UserModel? user = await getUser(post.auteurUid);

      if (user != null) {
        // Supprimer tous les commentaires associés au post et décrémenter le nombre de commentaires de l'utilisateur
        QuerySnapshot commentSnapshot = await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('posts')
            .doc(post.id)
            .collection('comments')
            .get();

        for (var doc in commentSnapshot.docs) {
          // Pour chaque commentaire, décrémenter le nombre de commentaires de l'utilisateur
          CommentModel comment = CommentModel.fromDocument(doc);
          await decrementUserCommentCount(comment.auteurUid);

          // Supprimer le commentaire
          await doc.reference.delete();
        }

        // Supprimer l'image du post si elle existe
        if (post.imageUrl.isNotEmpty) {
          Reference imageRef =
              FirebaseStorage.instance.refFromURL(post.imageUrl);
          await imageRef.delete();
        }

        // Mettre à jour les statistiques de l'utilisateur : décrémenter le nombre de posts et les upvotes reçus
        await _firestore.collection('utilisateurs').doc(user.uid).update({
          'nombreDePosts': FieldValue.increment(-1),
          'nombreDeUpvotesRecus': FieldValue.increment(-post.upvotes),
        });

        // Supprimer le post lui-même
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('posts')
            .doc(post.id)
            .delete();
      }
    } catch (e) {
      throw Exception("Erreur lors de la suppression du post : $e");
    }
  }

  // Méthode pour ajouter un document
  Future<void> addDocument(DocumentModel document) async {
    DocumentReference docRef = _firestore.collection('documents').doc();
    document.id = docRef.id;
    await docRef.set(document.toMap());
  }

  // Méthode pour supprimer un document
  Future<void> deleteDocument(String docId, String fileUrl) async {
    // Supprimer l'enregistrement dans Firestore
    await _firestore.collection('documents').doc(docId).delete();

    // Supprimer le fichier dans Firebase Storage
    final ref = _storage.refFromURL(fileUrl);
    await ref.delete();
  }

  // Méthode pour uploader un fichier
  Future<String> uploadFile(File file, String userId) async {
    final ref =
        _storage.ref().child('documents/$userId/${file.path.split('/').last}');
    await ref.putFile(file);
    return await ref.getDownloadURL(); // URL du fichier uploadé
  }

  // Méthode pour récupérer les documents d'un utilisateur
  Stream<List<DocumentModel>> getUserDocuments(String userId) {
    return _firestore
        .collection('documents')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

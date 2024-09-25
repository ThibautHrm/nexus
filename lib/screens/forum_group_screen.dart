import 'package:flutter/material.dart';
import 'package:nexus/models/group_model.dart';
import 'package:nexus/screens/forum_detail_screen.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/screens/add_group_screen.dart';
import 'package:nexus/models/user_model.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  GroupScreenState createState() => GroupScreenState();
}

class GroupScreenState extends State<GroupScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<GroupModel> _groupList = [];
  bool _isLoading = true;
  UserModel? _currentUser; // Stocker l'utilisateur actuel

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadCurrentUser(); // Charger les infos utilisateur
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<GroupModel> groups = await _firebaseService.getAllGroups();
      setState(() {
        _groupList = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _groupList = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    UserModel? user = await _firebaseService.getCurrentUserDetails();
    setState(() {
      _currentUser = user;
    });
  }

  void _navigateToGroupDetail(GroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupDetailScreen(group: group)),
    );
  }

  Future<void> _navigateToAddGroup() async {
    // Naviguer vers la page de création de groupe et attendre un résultat
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGroupScreen()),
    );

    // Vérifier si un groupe a été ajouté et recharger la liste si nécessaire
    if (result == true) {
      _loadGroups();
    }
  }

  // Widget pour chaque groupe
  Widget _buildGroupItem(GroupModel group) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          group.nom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        subtitle: Text(group.description),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: () => _navigateToGroupDetail(group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groupes"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupList.isEmpty
              ? const Center(child: Text("Aucun groupe disponible."))
              : ListView.builder(
                  itemCount: _groupList.length,
                  itemBuilder: (context, index) {
                    return _buildGroupItem(_groupList[index]);
                  },
                ),
      // Afficher le bouton de création de groupe uniquement si l'utilisateur est staff
      floatingActionButton:
          _currentUser != null && _currentUser!.role == 'staff'
              ? FloatingActionButton(
                  onPressed: _navigateToAddGroup,
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}

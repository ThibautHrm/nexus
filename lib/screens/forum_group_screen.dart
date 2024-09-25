import 'package:flutter/material.dart';
import 'package:nexus/models/group_model.dart';
import 'package:nexus/screens/forum_detail_screen.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/screens/add_group_screen.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/themes/app_colors.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  GroupScreenState createState() => GroupScreenState();
}

class GroupScreenState extends State<GroupScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<GroupModel> _groupList = [];
  bool _isLoading = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadCurrentUser();
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGroupScreen()),
    );

    if (result == true) {
      _loadGroups();
    }
  }

  Widget _buildGroupItem(GroupModel group) {
    return GestureDetector(
      onTap: () => _navigateToGroupDetail(group),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.secondary,
                child: Text(
                  group.nom.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Questrial',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        fontFamily: "Questrial",
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      group.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: "Questrial",
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text(
          "Groupes du Forum",
          style: TextStyle(
            color: AppColors.textDark,
            fontFamily: "Questrial",
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupList.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun groupe disponible.",
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontFamily: "Questrial",
                      fontSize: 18,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _groupList.length,
                  itemBuilder: (context, index) {
                    return _buildGroupItem(_groupList[index]);
                  },
                ),
      floatingActionButton:
          _currentUser != null && _currentUser!.role == 'staff'
              ? FloatingActionButton(
                  onPressed: _navigateToAddGroup,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/news_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/screens/news_details_screen.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  String _selectedEmplacement = 'Tous';
  UserModel? _currentUser;

  final List<String> _emplacements = [
    'Tous',
    'Angers',
    'Arras',
    'Auxerre',
    'Bordeaux',
    'Chartres',
    'Grenoble',
    'Lille',
    'Lyon',
    'Montpellier',
    'Nantes',
    'Paris',
    'Reims',
    'Rennes',
    'Saint-Étienne',
    'Toulouse',
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedEmplacement();
    _loadCurrentUser();
  }

  Future<void> _loadSelectedEmplacement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? emplacement = prefs.getString('selectedEmplacement');
    if (emplacement != null && !_emplacements.contains(emplacement)) {
      emplacement = 'Tous';
    }
    setState(() {
      _selectedEmplacement = emplacement ?? 'Tous';
      _isLoading = true;
    });
    String? emplacementQuery =
        _selectedEmplacement == 'Tous' ? null : _selectedEmplacement;
    await _loadNews(emplacement: emplacementQuery);
  }

  Future<void> _loadNews({String? emplacement}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<NewsModel> news =
          await _firebaseService.getAllNews(emplacement: emplacement);

      setState(() {
        _newsList = news;
        _isLoading = false;
      });
    } catch (e) {
      _newsList = [];
      _isLoading = false;
    }
  }

  Future<void> _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          _currentUser = UserModel.fromDocument(userDoc);
        });
      }
    }
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      toolbarHeight: 70,
      leadingWidth: 300,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: _buildUserInfo(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(
              Icons.circle_notifications,
              color: AppColors.primary,
              size: 38,
            ),
            onPressed: () {
              // Action de notification
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    if (_currentUser == null) {
      // Utilise une animation pendant le chargement
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: AppColors.primary,
          size: 30,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: CircleAvatar(
            radius: 24,
            backgroundImage: _currentUser?.photoProfil != null
                ? CachedNetworkImageProvider(_currentUser!.photoProfil!)
                : null,
            backgroundColor:
                _currentUser?.photoProfil == null ? AppColors.primary : null,
            child: _currentUser?.photoProfil == null
                ? const Icon(Icons.person, size: 24, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentUser?.nom ?? '',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: "Questrial",
                ),
              ),
              Text(
                _currentUser?.role ?? 'Étudiant',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontFamily: "Questrial",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return FittedBox(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: "Questrial",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmplacementFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _emplacements.map((String emplacement) {
          bool isSelected = _selectedEmplacement == emplacement;
          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedEmplacement = emplacement;
                _isLoading = true;
              });
              String? emplacementQuery =
                  _selectedEmplacement == 'Tous' ? null : _selectedEmplacement;
              await _loadNews(emplacement: emplacementQuery);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Center(
                child: Text(
                  emplacement,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Questrial",
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoNewsMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Aucune news disponible pour cet emplacement.',
          style: TextStyle(
            fontSize: 16.0,
            color: AppColors.textDark,
            fontFamily: "Questrial",
          ),
        ),
      ),
    );
  }

  Widget _buildNewsItem(NewsModel news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NewsDetailScreen(news: news),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Card(
        color: Colors.grey.shade100,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'newsImage_${news.id}',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: news.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: news.imageUrl,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: AppColors.primary,
                            size: 50,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, size: 100),
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey,
                        child: const Icon(Icons.image, size: 100),
                      ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                news.titre,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Questrial",
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text(
                news.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Questrial",
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16.0, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Text(
                    news.emplacement,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontFamily: "Questrial",
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today,
                      size: 16.0, color: AppColors.textDark),
                  const SizedBox(width: 4.0),
                  Text(
                    DateFormat.yMMMd('fr_FR').format(news.dateCreation),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontFamily: "Questrial",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffActionButton() {
    if (_currentUser?.role == 'Staff') {
      return _buildActionButton(
          "Poster Nouvelles", Icons.newspaper_rounded, AppColors.primary, () {
        Navigator.pushNamed(context, '/createNews');
      });
    } else {
      return _buildActionButton("Documents", Icons.folder, AppColors.primary,
          () {
        Navigator.pushNamed(context, '/locker');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildCustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/group');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Forum',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade100,
                                  fontFamily: "Questrial",
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Discussions ouvertes',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.backgroundLight,
                                  fontFamily: "Questrial",
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(
                              Icons.groups,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                            "Signaler",
                            Icons.assistant_photo_rounded,
                            AppColors.primary, () {
                          Navigator.pushNamed(context, '/signal');
                        }),
                        _buildStaffActionButton(),
                        _buildActionButton(
                            "Planning",
                            Icons.calendar_month_rounded,
                            AppColors.primary, () {
                          // Action pour le planning
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Les News",
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Questrial",
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            _buildEmplacementFilter(),
            const SizedBox(height: 20),
            _isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.primary,
                      size: 50,
                    ),
                  )
                : _newsList.isEmpty
                    ? _buildNoNewsMessage()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _newsList.length,
                        itemBuilder: (context, index) {
                          return _buildNewsItem(_newsList[index]);
                        },
                      ),
          ],
        ),
      ),
    );
  }
}

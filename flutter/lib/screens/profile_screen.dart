import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "../components/sidenav.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "../services/profile_service.dart";
import "../screens/note_screen.dart";

class RelationshipPage extends StatefulWidget {
  const RelationshipPage({super.key});

  @override
  State<RelationshipPage> createState() => _RelationshipPageState();
}

class _RelationshipPageState extends State<RelationshipPage> {
  Map<String, dynamic> selectedRelationship = {};
  String? _authToken;
  String? _userId;

  void showSnackBar(BuildContext context, String message) {
    if (mounted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(message), duration: Duration(seconds: 3)),
      // );

      final overLay = Overlay.of(context);
      final overLayComponent = OverlayEntry(
        builder: (context) {
          return Positioned(
            bottom: 20,
            right: 10,
            left: 10,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      );

      overLay.insert(overLayComponent);

      Future.delayed(Duration(seconds: 3), () {
        overLayComponent.remove();
      });
    }
  }

  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      setState(() {
        _authToken = token;
        _userId = userId;
      });

      if ((token == null || userId == null) && mounted) {
        showSnackBar(context, "Authentication token or UserId not found");
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to load authentication: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  void getProfilesFunct(String profileId) async {
    if (_authToken == null || _userId == null) {
      showSnackBar(context, "Authentication token or User ID not found.");
      return;
    }

    final response = await ProfileService.getProfileById(
      _userId!,
      profileId,
      _authToken!,
    );

    if (response["success"]) {
      final relationshipObject = response["data"]["profile"];
      setState(() {
        selectedRelationship = Map<String, dynamic>.from(relationshipObject);
      });
    } else if (mounted) {
      showSnackBar(context, response["error"] ?? "Failed to load profile");
    }
  }

  // Profile-specific search function
  Future<Map<String, dynamic>> _searchProfiles(
    String query,
    String token,
    String userId,
  ) async {
    return ProfileService.searchProfiles(query, token, userId);
  }

  // Profile-specific title extractor
  String _extractProfileTitle(Map<String, dynamic> profile) {
    return profile["profileTitle"] ?? "Untitled";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Color.fromRGBO(0, 0, 0, 0.75),

      // This is the navbar at the top
      appBar: AppBar(
        title: Text(
          'Relationship',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.05,
            height: 1.75 / 1.125,
          ),
        ),
        toolbarHeight: 53.5,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(height: 0.5, color: Colors.white),
        ),
      ),

      // The display for the selectedProfile
      body:
          selectedRelationship.isEmpty
              // Nothing Selected
              ? Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/ghost-icon.svg",
                      semanticsLabel: "Ghost Icon",
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      width: 75,
                      height: 75,
                      placeholderBuilder:
                          (context) => Container(
                            padding: EdgeInsets.all(15),
                            child: CircularProgressIndicator(),
                          ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No Profile Selected",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        height: 1.3333,
                        fontFamily: "Montserrat",
                        fontFamilyFallback: ["sans-serif"],
                      ),
                    ),
                  ],
                ),
              )
              // Profile is Selected
              : SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 900),
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedRelationship["profileTitle"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 36,
                            height: 1.1111,
                            fontFamily: "Montserrat",
                            fontFamilyFallback: ["sans-serif"],
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "${selectedRelationship["profileContent"]}",
                          style: TextStyle(fontSize: 18, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

      // Use the dynamic SideNav with profile-specific functions and callbacks
      drawer: SideNav(
        userId: _userId,
        selectedItemId: selectedRelationship["_id"],
        token: _authToken,
        showSnackBar: showSnackBar,
        searchFunction: _searchProfiles,
        titleExtractor: _extractProfileTitle,
        searchPlaceholder: "Search Profiles",
        dataKey: "profiles",
        onItemSelected: getProfilesFunct,
        isNotesActive: false,
        isPeopleActive: true,
        onNotesPageSelected: () {
          // Navigate to note screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NoteScreen()),
          );
        },
        onPeoplePageSelected: () {
          // Already on people page, just close drawer
          Navigator.pop(context);
        },
        onItemTap: (context, profileId) {
          // Load profile data and close,
          getProfilesFunct(profileId);
          Navigator.pop(context);
        },
      ),
    );
  }
}

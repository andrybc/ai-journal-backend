import 'package:flutter/material.dart';
import "../components/sidenav.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "../services/profile_service.dart";
import "../screens/note_screen.dart";
import '../styles/index.dart';

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
      AppUI.showSnackBar(context, message);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawerScrimColor: Colors.black.withOpacity(0.75),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.2,

      // This is the navbar at the top
      appBar: AppBar(
        title: Text(
          'Relationship',
          style: AppTextStyle.appBarTitle,
        ),
        toolbarHeight: 53.5,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),

      // The display for the selectedProfile
      body: selectedRelationship.isEmpty
          // Nothing Selected
          ? AppUI.emptyState(
              icon: "assets/icons/ghost-icon.svg",
              title: "No Profile Selected",
              subtitle: 'Select a profile from the sidebar or create a new one',
              onActionPressed: () {
                // Action to create new profile
                // Add implementation here when needed
              },
              actionText: "Create New Profile",
            )
          // Profile is Selected
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
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
                        style: AppTextStyle.h1,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "${selectedRelationship["profileContent"]}",
                        style: AppTextStyle.body,
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

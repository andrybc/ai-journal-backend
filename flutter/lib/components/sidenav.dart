import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class SideNav extends StatefulWidget {
  final String? userId;
  final String? selectedItemId;
  final String? token;
  final Function(BuildContext context, String message) showSnackBar;

  // Service functions and customization properties
  final Future<Map<String, dynamic>> Function(String, String, String)
  searchFunction;
  final String Function(Map<String, dynamic>) titleExtractor;
  final String searchPlaceholder;
  final String
  dataKey; // The key to extract data from response (e.g. "profiles" or "notebooks")

  // Navigation callbacks
  final Function(String) onItemSelected; // Callback when an item is selected
  final VoidCallback
  onNotesPageSelected; // Callback when notes page button is tapped
  final VoidCallback
  onPeoplePageSelected; // Callback when people page button is tapped
  final bool isNotesActive; // Whether notes view is active (for highlighting)
  final bool isPeopleActive; // Whether people view is active (for highlighting)
  final Function(BuildContext, String)
  onItemTap; // Callback when an item is tapped (for navigation)

  const SideNav({
    required this.userId,
    required this.selectedItemId,
    required this.token,
    required this.showSnackBar,
    required this.searchFunction,
    required this.titleExtractor,
    required this.searchPlaceholder,
    required this.dataKey,
    required this.onItemSelected,
    required this.onNotesPageSelected,
    required this.onPeoplePageSelected,
    required this.isNotesActive,
    required this.isPeopleActive,
    required this.onItemTap,
    super.key,
  });

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  String? _displayUsername;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.userId == null || widget.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.showSnackBar(
          context,
          "Authentication token or User ID not found.",
        );
      });
    } else {
      searchItems("");
      print("calling _fetchUsername()");
      _fetchUsername();
    }
  }

  Future<void> _fetchUsername() async {
    if (widget.userId == null || widget.token == null) return;

    try {
      final response = await UserService.getUserById(
        widget.userId!,
        widget.token!,
      );

      if (response["success"] && response["data"] != null) {
        print("data : ${response["data"]}");
        setState(() {
          _displayUsername = response["data"]["username"];
        });
      }
    } catch (e) {
      debugPrint('Error fetching username: $e');
    }
  }

  // Handle logout - clear SharedPreferences and navigate to login screen
  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      // Show success message
      widget.showSnackBar(context, 'Logged out successfully');

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      widget.showSnackBar(context, 'Error logging out: $e');
    }
  }

  void searchItems(String query) async {
    if (widget.userId == null || widget.token == null) {
      widget.showSnackBar(
        context,
        "Authentication token or User ID not found.",
      );
      return;
    }

    try {
      // Use the provided search function
      print("userId: ${widget.userId}");
      print("token: ${widget.token}");
      final response = await widget.searchFunction(
        query,
        widget.token!,
        widget.userId!,
      );

      if (response["success"]) {
        // Use the provided data key to extract items
        final itemList = response["data"][widget.dataKey];
        setState(() {
          items = List<Map<String, dynamic>>.from(itemList ?? []);
        });
      } else if (mounted) {
        widget.showSnackBar(
          context,
          response["error"] ?? "Failed to search items",
        );
      }
    } catch (e) {
      if (mounted) {
        widget.showSnackBar(context, "Error searching: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Top Navigation part
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Close Nav Icon
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/close-nav-icon.svg",
                    semanticsLabel: "Close Nav Icon",
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      theme.iconTheme.color ?? Colors.white,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder:
                        (context) => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        ),
                  ),
                ),

                const Spacer(),

                //Notes Page Button
                NavigationBarTheme(
                  data: NavigationBarThemeData(
                    indicatorColor: theme.colorScheme.secondaryContainer,
                  ),
                  child: IconButton(
                    isSelected: widget.isNotesActive,
                    onPressed: widget.onNotesPageSelected,
                    icon: SvgPicture.asset(
                      "assets/icons/notes-page-icon.svg",
                      semanticsLabel: "Notes Page Icon",
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        theme.iconTheme.color ?? Colors.white,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder:
                          (context) => const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // People Page Button
                NavigationBarTheme(
                  data: NavigationBarThemeData(
                    indicatorColor: theme.colorScheme.secondaryContainer,
                  ),
                  child: IconButton(
                    isSelected: widget.isPeopleActive,
                    onPressed: widget.onPeoplePageSelected,
                    icon: SvgPicture.asset(
                      "assets/icons/people-relationship-icon.svg",
                      semanticsLabel: "People Relationship Icon",
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        theme.iconTheme.color ?? Colors.white,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder:
                          (context) => const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              onChanged: (value) {
                searchItems(value);
              },
              hintText: widget.searchPlaceholder,
              padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
              leading: const Icon(Icons.search),
            ),
          ),

          // List of Items (Profiles or Notebooks)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final isSelected = widget.selectedItemId == items[index]["_id"];

                return ListTile(
                  selected: isSelected,
                  title: Text(
                    widget.titleExtractor(items[index]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Call onItemSelected with the ID
                    widget.onItemSelected(items[index]["_id"]);

                    // Call onItemTap with context and ID for navigation
                    widget.onItemTap(context, items[index]["_id"]);
                  },
                );
              },
            ),
          ),

          // User Options Section
          const Divider(height: 1),

          ListTile(
            leading: CircleAvatar(
              child: SvgPicture.asset(
                "assets/icons/contact-icon.svg",
                semanticsLabel: "User Contact Icon",
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.iconTheme.color ?? Colors.white,
                  BlendMode.srcIn,
                ),
                placeholderBuilder:
                    (context) => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
              ),
            ),
            title: Text(
              _displayUsername ?? "User Name",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: _handleLogout,
              icon: SvgPicture.asset(
                "assets/icons/logout-icon.svg",
                semanticsLabel: "Logout Icon",
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.iconTheme.color ?? Colors.white,
                  BlendMode.srcIn,
                ),
                placeholderBuilder:
                    (context) => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

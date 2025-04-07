import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      width: 300,
      child: Column(
        children: [
          // Top Navigation part
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Close Nav Icon
                IconButton(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/close-nav-icon.svg",
                    semanticsLabel: "Close Nav Icon",
                    width: 25,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder:
                        (context) => SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                  ),
                ),

                Spacer(),

                //Notes Page Button
                IconButton(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor:
                        widget.isNotesActive
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                  ),
                  onPressed: widget.onNotesPageSelected,
                  icon: SvgPicture.asset(
                    "assets/icons/notes-page-icon.svg",
                    semanticsLabel: "Notes Page Icon",
                    width: 25,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder:
                        (context) => SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                  ),
                ),

                SizedBox(width: 12),

                // People Page Button
                IconButton(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor:
                        widget.isPeopleActive
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                  ),
                  onPressed: widget.onPeoplePageSelected,
                  icon: SvgPicture.asset(
                    "assets/icons/people-relationship-icon.svg",
                    semanticsLabel: "People Relationship Icon",
                    width: 25,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder:
                        (context) => SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                searchItems(value);
              },
              cursorHeight: 24,
              cursorColor: Colors.white,
              cursorWidth: 1,
              style: TextStyle(fontSize: 16, height: 1.5),
              decoration: InputDecoration(
                constraints: BoxConstraints(maxHeight: 40),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                hintText: widget.searchPlaceholder,
                hintStyle: TextStyle(fontSize: 16, height: 1.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white, width: 0.5),
                ),
              ),
            ),
          ),

          SizedBox(height: 14),

          // List of Items (Profiles or Notebooks)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 14),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 4),

                  //Individual Item
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor:
                          widget.selectedItemId == items[index]["_id"]
                              ? Color.fromRGBO(209, 213, 219, 1)
                              : Colors.transparent,
                    ),
                    onPressed: () {
                      // Call onItemSelected with the ID
                      widget.onItemSelected(items[index]["_id"]);

                      // Call onItemTap with context and ID for navigation
                      widget.onItemTap(context, items[index]["_id"]);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        widget.titleExtractor(items[index]),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 14),

          // User Options Section
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/contact-icon.svg",
                    semanticsLabel: "User Contact Icon",
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder:
                        (context) => SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(),
                        ),
                  ),
                ),
                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "User Name",
                    style: TextStyle(fontSize: 18, height: 1.75 / 1.125),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(width: 12),

                // Logout Button
                IconButton(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/logout-icon.svg",
                    semanticsLabel: "Logout Icon",
                    width: 25,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder:
                        (context) => SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

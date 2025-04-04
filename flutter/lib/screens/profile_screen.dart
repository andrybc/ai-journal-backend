import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "../services/api_service.dart";

class RelationshipPage extends StatefulWidget {
  const RelationshipPage({super.key});

  @override
  State<RelationshipPage> createState() => _RelationshipPageState();
}

class _RelationshipPageState extends State<RelationshipPage> {
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic> selectedRelationship = {
    "profileTitle": "John Doe",
    "_id": 1,
    "profileContent":
        "John Doe is a name that has long been associated with anonymity, mystery, and adaptability. Used widely in legal, medical, and fictional contexts, John Doe can represent an unidentified individual, a person seeking to keep their identity secret, or even a symbol of the everyday, average person. Over time, the name has evolved beyond its practical applications and taken on a cultural significance, appearing in literature, film, and media as an archetype of the unknown or forgotten man. In legal and medical settings, John Doe (or Jane Doe for females) is a placeholder used when an individual's real name is unknown or cannot be disclosed. This practice dates back centuries and is still commonly employed today in court cases, autopsies, and police investigations. Whether it is an unidentified body, a witness who wishes to remain anonymous, or a defendant whose identity is unknown, the name John Doe serves as a neutral stand-in, allowing proceedings to move forward without revealing sensitive or unavailable information. Beyond legal and administrative use, John Doe has taken on a broader cultural and symbolic role. In fiction, he is often depicted as an everyman character—someone without distinguishing traits or a unique identity, representing the common person in society. At the same time, John Doe can also be used to portray someone shrouded in mystery, an individual with a hidden past, a secret identity, or even a person who has been erased from public records. In crime dramas, thrillers, and conspiracy narratives, the name is frequently attached to characters who either do not remember their past or are deliberately concealed from the world. In the realm of psychological and philosophical discussions, John Doe serves as a symbol of the faceless masses, the countless individuals who go unnoticed in the grand scheme of history. His identity—or lack thereof—raises questions about individuality, anonymity, and the significance of a name. It also touches on themes of existentialism, as a person labeled John Doe may struggle with their own sense of self, especially if the name is imposed upon them due to circumstances beyond their control. Despite his anonymity, John Doe is paradoxically well-known. The name is instantly recognizable and understood across different cultures and contexts. Whether he is the victim of a crime, a witness seeking protection, or a protagonist in a gripping mystery, John Doe remains one of the most famous unknown figures in history. His identity may be uncertain, but his presence is undeniably significant.",
  };

  List<Map<String, dynamic>> profiles = [];
  final String userId = "67f0162886e4016aee74ed9f";

  void searchProfilesFunct(String query) async {
    final response = await ApiService().searchProfiles(query, userId);

    if (response["success"]) {
      setState(() {
        profiles = response["profiles"];
      });
    } else {
      print(response["errorMessage"]);
    }
  }

  void getProfilesFunct(int profileId) async {
    final response = await ApiService().getProfile(profileId, userId);

    if (response["success"]) {
      setState(() {
        selectedRelationship = response["profile"];
      });
    } else {
      print(response["errorMessage"]);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchProfilesFunct("");
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
          child: Container(height: 0.5, color: Colors.black),
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
                      "icons/ghost-icon.svg",
                      semanticsLabel: "Ghost Icon",
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

      // SideNav bar
      drawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        width: 300,
        child: Column(
          children: [
            // Top Navigation part
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 0.5),
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
                      "icons/close-nav-icon.svg",
                      semanticsLabel: "Close Nav Icon",
                      width: 25,
                      height: 25,
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
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      "icons/notes-page-icon.svg",
                      semanticsLabel: "Notes Page Icon",
                      width: 25,
                      height: 25,
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
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      "icons/people-relationship-icon.svg",
                      semanticsLabel: "People Relationship Icon",
                      width: 25,
                      height: 25,
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
                  searchProfilesFunct(value);
                },
                cursorHeight: 24,
                cursorColor: Colors.black,
                cursorWidth: 1,
                style: TextStyle(fontSize: 16, height: 1.5),
                decoration: InputDecoration(
                  constraints: BoxConstraints(maxHeight: 40),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  hintText: "Search Profiles",
                  hintStyle: TextStyle(fontSize: 16, height: 1.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black, width: 0.5),
                  ),
                ),
              ),
            ),

            SizedBox(height: 14),

            // List of Profiles
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 14),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 4),

                    //Individual Profile
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            selectedRelationship["_id"] ==
                                    profiles[index]["_id"]
                                ? Color.fromRGBO(209, 213, 219, 1)
                                : Colors.transparent,
                      ),
                      onPressed: () {
                        setState(() {
                          getProfilesFunct(profiles[index]["_id"]);
                          Navigator.pop(context);
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "${profiles[index]["profileTitle"]}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
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
                border: Border(
                  top: BorderSide(color: Colors.black, width: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      "icons/contact-icon.svg",
                      semanticsLabel: "User Contact Icon",
                      width: 30,
                      height: 30,
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
                      "icons/logout-icon.svg",
                      semanticsLabel: "Logout Icon",
                      width: 25,
                      height: 25,
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
      ),
    );
  }
}

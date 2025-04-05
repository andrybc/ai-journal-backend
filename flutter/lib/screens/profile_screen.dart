import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "../services/api_service.dart";
import "../components/sidenav_profile.dart";

class RelationshipPage extends StatefulWidget {
  const RelationshipPage({super.key});

  @override
  State<RelationshipPage> createState() => _RelationshipPageState();
}

class _RelationshipPageState extends State<RelationshipPage> {
  Map<String, dynamic> selectedRelationship = {
    "profileTitle": "John Doe",
    "_id": 1,
    "profileContent":
        "John Doe is a name that has long been associated with anonymity, mystery, and adaptability. Used widely in legal, medical, and fictional contexts, John Doe can represent an unidentified individual, a person seeking to keep their identity secret, or even a symbol of the everyday, average person. Over time, the name has evolved beyond its practical applications and taken on a cultural significance, appearing in literature, film, and media as an archetype of the unknown or forgotten man. In legal and medical settings, John Doe (or Jane Doe for females) is a placeholder used when an individual's real name is unknown or cannot be disclosed. This practice dates back centuries and is still commonly employed today in court cases, autopsies, and police investigations. Whether it is an unidentified body, a witness who wishes to remain anonymous, or a defendant whose identity is unknown, the name John Doe serves as a neutral stand-in, allowing proceedings to move forward without revealing sensitive or unavailable information. Beyond legal and administrative use, John Doe has taken on a broader cultural and symbolic role. In fiction, he is often depicted as an everyman character—someone without distinguishing traits or a unique identity, representing the common person in society. At the same time, John Doe can also be used to portray someone shrouded in mystery, an individual with a hidden past, a secret identity, or even a person who has been erased from public records. In crime dramas, thrillers, and conspiracy narratives, the name is frequently attached to characters who either do not remember their past or are deliberately concealed from the world. In the realm of psychological and philosophical discussions, John Doe serves as a symbol of the faceless masses, the countless individuals who go unnoticed in the grand scheme of history. His identity—or lack thereof—raises questions about individuality, anonymity, and the significance of a name. It also touches on themes of existentialism, as a person labeled John Doe may struggle with their own sense of self, especially if the name is imposed upon them due to circumstances beyond their control. Despite his anonymity, John Doe is paradoxically well-known. The name is instantly recognizable and understood across different cultures and contexts. Whether he is the victim of a crime, a witness seeking protection, or a protagonist in a gripping mystery, John Doe remains one of the most famous unknown figures in history. His identity may be uncertain, but his presence is undeniably significant.",
  };

  final String userId = "67f0162886e4016aee74ed9f";

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
      drawer: SideNavProfile(
        userId: userId,
        onProfileSelected: (profileId) => getProfilesFunct(profileId),
        selectedProfileId: selectedRelationship["_id"],
      ),
    );
  }
}

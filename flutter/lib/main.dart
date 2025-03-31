import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "../.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RelationshipPage(),
    );
  }
}

class RelationshipPage extends StatefulWidget {
  const RelationshipPage({super.key});

  @override
  State<RelationshipPage> createState() => _RelationshipPageState();
}

class _RelationshipPageState extends State<RelationshipPage> {
  Map<String, dynamic> selectedRelationship = {
    "name": "John Doe",
    "id": 1,
    "summary":
        "John Doe is a name that has long been associated with anonymity, mystery, and adaptability. Used widely in legal, medical, and fictional contexts, John Doe can represent an unidentified individual, a person seeking to keep their identity secret, or even a symbol of the everyday, average person. Over time, the name has evolved beyond its practical applications and taken on a cultural significance, appearing in literature, film, and media as an archetype of the unknown or forgotten man. In legal and medical settings, John Doe (or Jane Doe for females) is a placeholder used when an individual's real name is unknown or cannot be disclosed. This practice dates back centuries and is still commonly employed today in court cases, autopsies, and police investigations. Whether it is an unidentified body, a witness who wishes to remain anonymous, or a defendant whose identity is unknown, the name John Doe serves as a neutral stand-in, allowing proceedings to move forward without revealing sensitive or unavailable information. Beyond legal and administrative use, John Doe has taken on a broader cultural and symbolic role. In fiction, he is often depicted as an everyman character—someone without distinguishing traits or a unique identity, representing the common person in society. At the same time, John Doe can also be used to portray someone shrouded in mystery, an individual with a hidden past, a secret identity, or even a person who has been erased from public records. In crime dramas, thrillers, and conspiracy narratives, the name is frequently attached to characters who either do not remember their past or are deliberately concealed from the world. In the realm of psychological and philosophical discussions, John Doe serves as a symbol of the faceless masses, the countless individuals who go unnoticed in the grand scheme of history. His identity—or lack thereof—raises questions about individuality, anonymity, and the significance of a name. It also touches on themes of existentialism, as a person labeled John Doe may struggle with their own sense of self, especially if the name is imposed upon them due to circumstances beyond their control. Despite his anonymity, John Doe is paradoxically well-known. The name is instantly recognizable and understood across different cultures and contexts. Whether he is the victim of a crime, a witness seeking protection, or a protagonist in a gripping mystery, John Doe remains one of the most famous unknown figures in history. His identity may be uncertain, but his presence is undeniably significant.",
  };

  List<Map<String, dynamic>> profiles = [];
  final userId = 1;

  Future<void> searchProfiles(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${dotenv.env["VITE_API_URL"]}/profile/search?userId=$userId&query=${Uri.encodeComponent(query)}",
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print(responseData["message"]);
        setState(() {
          profiles = responseData["profiles"];
        });
      } else {
        final errorMessage = jsonDecode(response.body);
        throw Exception(
          errorMessage["error"] ??
              "Unexpected error while searching for profiles",
        );
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> getProfile(int profileId) async {
    try {
      final response = await http.get(
        Uri.parse("${dotenv.env["VITE_API_URL"]}/profile/$userId/$profileId"),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print(responseData["message"]);
        setState(() {
          selectedRelationship = responseData["profile"];
        });
      } else {
        final errorMessage = jsonDecode(response.body);
        throw Exception(
          errorMessage["error"] ?? "Unexpected error while retrieving profile",
        );
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchProfiles("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Color.fromRGBO(0, 0, 0, 0.75),
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
      body:
          selectedRelationship.isEmpty
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
                          "${selectedRelationship["name"]}",
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
                          "${selectedRelationship["summary"]}",
                          style: TextStyle(fontSize: 18, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        width: 300,
        child: Column(
          children: [
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
                  IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(6),
                      minimumSize: Size(25, 25),
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
                  IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(6),
                      minimumSize: Size(25, 25),
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
                  IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(6),
                      minimumSize: Size(25, 25),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
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
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 14),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            selectedRelationship["id"] == profiles[index]["id"]
                                ? Color.fromRGBO(209, 213, 219, 1)
                                : Colors.transparent,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRelationship = profiles[index];
                          Navigator.pop(context);
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "${profiles[index]["name"]}",
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
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

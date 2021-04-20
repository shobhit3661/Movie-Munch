import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movie_munch/screens/home_screen.dart';
import 'package:movie_munch/screens/welcome_screen.dart';

final _auth = FirebaseAuth.instance;
User loggedInUser;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _defaultHome = new WelcomeScreen();
    final user = _auth.currentUser;
    if (user != null) {
      _defaultHome = new HomeScreen();
    }
    return MaterialApp(
      title: 'Movie munch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _defaultHome,
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomeScreen(),
        '/login': (BuildContext context) => new WelcomeScreen(),
      },
    );
  }
}

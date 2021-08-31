import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:smartfreezer/Auth.dart';
import 'package:smartfreezer/bluetooth/Home.dart';
import 'package:smartfreezer/SignIn.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  Widget currentPage = SignIn();
  AuthClass authClass = AuthClass();
  @override 
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();

  }
  void checkLogin() async {
    String? token = await authClass.getToken();
    if (token != null) {
      setState(() {
        currentPage = MainPage();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       home: currentPage,
 //home: WifiInput(),
    );
  }
}

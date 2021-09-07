import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:smartfreezer/RegisterPage/Auth.dart';
import 'package:smartfreezer/bluetooth/Home.dart';
import 'package:smartfreezer/RegisterPage/SignIn.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  bool circular = false;

  AuthClass authClass = AuthClass();

  get app => null;

  bool hide = true;
  void buttonHandler() => setState(() => hide = !hide);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
            ),
            Text(
              "Sign Up",
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(
              height: 30,
            ),
            textfield(_emailController, false, "email"),
            textfield(_pwdController, true, "password"),
            button(),
            TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (builder) => SignIn()),
                      (route) => false);
                },
                child: Text("Already have an account")),
          ],
        ),
      ),
    ));
  }

  Widget button() {
    return TextButton(
        onPressed: () async {
          setState(() {
            circular = true;
          });
          try {
            firebase_auth.UserCredential userCredential =
                await firebaseAuth.createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _pwdController.text);
            setState(() {
              circular = false;
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => MainPage()),
                (route) => false);
          } catch (e) {
            final snackbar = SnackBar(content: Text(e.toString()));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
            setState(() {
              circular = false;
            });
          }
        },
        child: Text("Sign Up"));
  }

  Widget textfield(
      TextEditingController controller, bool obscure, String hinttext) {
    return TextFormField(
      decoration: InputDecoration(hintText: hinttext),
      controller: controller,
      obscureText: (obscure) ? hide : false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smartfreezer/Freezer/AddFreezer.dart';
import 'package:smartfreezer/RegisterPage/SignUp.dart';
import 'Auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  get app => null;
  bool hide = true;

  void buttonHandler() => setState(() => hide = !hide);

  bool circular = false;
  AuthClass authClass = AuthClass();
  

  
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
              "Log In",
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(
              height: 30,
            ),
            textfields(_emailController, false, "Email"),
            textfields(_pwdController, true, "Password"),
            colorbutton("Log In"),
            TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (builder) => SignUp()),
                      (route) => false);
                },
                child: Text("Create an account")),
          ],
        ),
      ),
    ));
  }

  Widget colorbutton(String text) {
    return TextButton(
        onPressed: () async {
          try {
            firebase_auth.UserCredential userCredential =
                await firebaseAuth.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _pwdController.text);
            setState(() {
              circular = false;
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => AddFreezer()),
                (route) => false);
          } catch (e) {
            final snackbar = SnackBar(content: Text(e.toString()));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
            setState(() {
              circular = false;
            });
          }
        },
        child: Text(text));
  }

  Widget textfields(TextEditingController controller, bool obscure, String hinttext) {
    return TextFormField(
      controller: controller,
      obscureText: (obscure) ? hide : false,
      decoration: InputDecoration(
        hintText: hinttext
      ),
    );
  }
}

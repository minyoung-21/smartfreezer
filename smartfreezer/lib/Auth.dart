import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthClass {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();
  
  Future<void> storeTokenAndData(UserCredential userCredential) async {
    await storage.write(
        key: "token", value: userCredential.credential!.token.toString());
    await storage.write(
        key: "userCredential", value: userCredential.toString());
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<String?> logout() async {
    try {
      // await _googleSignIn.signOut();
      await _auth.signOut();
      await storage.delete(key: "token");
    } catch (e) {}
  }

  void showSnackBar(BuildContext context, String text) {
    final snackbar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}

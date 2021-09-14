import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Action.dart';

class FreezerInfo extends StatefulWidget {
  late final String freezertitle;

  FreezerInfo({Key? key, required this.freezertitle}) : super(key: key);
  @override
  _FreezerInfoState createState() => _FreezerInfoState(this.freezertitle);
}

class _FreezerInfoState extends State<FreezerInfo> {
  late final String freezertitle;
  _FreezerInfoState(this.freezertitle);

  final uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference db =
      FirebaseDatabase.instance.reference().child("Freezer/randomly generated");
  late DatabaseReference _freezerref;
  late DataSnapshot data;
  var retrieved;
  temperature() {
    db.child("Temp").once().then((DataSnapshot snapshot) {
      setState(() {
        retrieved = snapshot.value.toString();
      });
    });
  }  
  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase();
    _freezerref = db.reference();
    super.initState();
  }

  

  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    temperature();
    return Scaffold(
        drawer: ActionBut(),
        appBar: AppBar(
          centerTitle: true,
          title: Text(freezertitle),
        ),
        body: Column(
          children: [
            Container(
              child: Text(retrieved ?? "", style: TextStyle(
                fontSize: 100
              ),),
              
            ),Text("Degree Celcius"),
            SizedBox(
              height: 100,
            ),
            Center(
              child: Transform.scale(
                scale: 2.0,
                child: CupertinoSwitch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                      db.update({
                        'Bool': isSwitched,
                      }).then((_) {});
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
            )
          ],
        ));
  }
}

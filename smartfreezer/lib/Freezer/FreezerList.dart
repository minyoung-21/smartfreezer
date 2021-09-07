import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Edit.dart';
import 'Info.dart';
import '../Action.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class YourListViewItem extends StatefulWidget {
  final String title;
  final String subtitle;

  const YourListViewItem({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);
  @override
  _YourListViewItemState createState() =>
      _YourListViewItemState(this.title, this.subtitle);
}

class _YourListViewItemState extends State<YourListViewItem> {
  late final String title;
  late final String sub;
  _YourListViewItemState(this.title, this.sub);
  DatabaseReference db =
      FirebaseDatabase.instance.reference().child("Freezer/randomly generated");
  late DatabaseReference _freezerref;
  late DataSnapshot data;

  @override
  void initState() {
    initializing();
    tz.initializeTimeZones();
    final FirebaseDatabase database = FirebaseDatabase();
    _freezerref = db.reference().child(uid);
    super.initState();
  }

  var retrieved;
  selectedTime() {
    db.child("Time").once().then((DataSnapshot snapshot) {
      setState(() {
        retrieved = snapshot.value;
      });
    });
  }

  bool isSwitched = false;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    selectedTime();
    String d = DateFormat("hh:mm a").format(DateTime.now());
    return Card(
        child: Column(
      children: [
        ListTile(
          title: new Text(widget.title),
          subtitle: new Text(retrieved ?? ""),
          trailing: new CupertinoSwitch(
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
                if (isSwitched == true) {
                  db.child("Time").once().then((DataSnapshot snapshot) {
                    if (snapshot.value == d) {
                      print("object");
                    }
                  });
                }
              });
            },
          ),
        ),
      ],
    ));
  }
}

class FreezerList extends StatefulWidget {
  late final FirebaseApp app;

  FreezerList({Key? key}) : super(key: key);
  @override
  _FreezerListState createState() => _FreezerListState();
}

class _FreezerListState extends State<FreezerList> {
  final textcontroller = TextEditingController();
  final databaseRef = FirebaseDatabase.instance.reference();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late DatabaseReference _freezerref;
  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase();
    _freezerref = databaseRef.reference().child("User").child(uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ActionBut(),
      appBar: AppBar(
        title: Text('Freezer List'),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        new FirebaseAnimatedList(
          shrinkWrap: true,
          query: _freezerref,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            return Column(
              children: [
                YourListViewItem(
                    title: snapshot.value['FreezerName'],
                    subtitle: snapshot.value['RandomGen']),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => EditDialog(
                                    fn: snapshot.value['FreezerName'],
                                    randomGenerated: "",
                                  ));
                        },
                        child: Text("Edit")),
                    TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => FreezerInfo(
                                        freezertitle:
                                            snapshot.value['FreezerName'],
                                      )),
                              (route) => false);
                        },
                        child: Text("Info"))
                  ],
                )
              ],
            );
          },
        )
      ])),
    );
  }
}

void initializing() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

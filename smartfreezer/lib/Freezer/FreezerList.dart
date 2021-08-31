// ignore: unused_import
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
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class YourListViewItem extends StatefulWidget {
  final String title;
  // final String subtitle;

  const YourListViewItem({
    Key? key,
    required this.title,
    // required this.subtitle,
  }) : super(key: key);

  @override
  _YourListViewItemState createState() => _YourListViewItemState();
}

class _YourListViewItemState extends State<YourListViewItem> {
  late DatabaseReference _freezerref;
  @override
  void initState() {
    initializing();
    tz.initializeTimeZones();
    final FirebaseDatabase database = FirebaseDatabase();
    _freezerref = databaseRef.reference().child(uid);
    super.initState();
  }

  bool isSwitched = false;

  final textcontroller = TextEditingController();
  final databaseRef = FirebaseDatabase.instance
      .reference()
      .child("Freezer")
      .child("randomly generated");
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    String d = DateFormat("hh:mm a").format(DateTime.now());
    return Card(
        child: Column(
      children: [
        ListTile(
          title: new Text(widget.title),
          // subtitle: rn,
          trailing: new CupertinoSwitch(
            value: isSwitched,
            // activeColor: Colors.pink,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
                //   if (isSwitched == true) {
                //     if (d == rn) {
                //       _showNotification(widget.title, rn);
                //       databaseRef.update({
                //         'Bool': true,
                //       }).then((_) {});
                //     }
                //   }
                
              });
            },
          ),
        ),
      ],
    ));
  }

  Future<void> _showNotification(
    String title,
    String body,
  ) async {
    flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
        NotificationDetails(
          android: AndroidNotificationDetails(
              'channel id', 'channel name', 'channel des'),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
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
  final Future<FirebaseApp> _future = Firebase.initializeApp();

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
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => EditDialog(
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

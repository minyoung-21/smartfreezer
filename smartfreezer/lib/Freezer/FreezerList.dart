import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'Edit.dart';
import 'Info.dart';
import '../Action.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

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
                      int hour = int.parse(snapshot.value.split(":")[0]);
                      String min1 = snapshot.value.split(":")[1];
                      int min = int.parse(min1.split(" ")[0]);
                      String am = min1.split(" ")[1];
                      if (am == "PM" && hour !=12) {
                        hour += 12;
                        print(hour);
                        scheduled(hour, min);
                      }
                      scheduled(hour, min);
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

  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void scheduled(int hour, int minute) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        // _nextInstanceOfTenAM(hour, minute),
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description')),
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
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

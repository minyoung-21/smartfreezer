// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:date_format/date_format.dart';
import 'package:smartfreezer/Action.dart';
import '../RegisterPage/Auth.dart';
import 'FreezerList.dart';
import 'package:intl/intl.dart';

import '../RegisterPage/SignIn.dart';

class AddFreezer extends StatefulWidget {
  late final FirebaseApp app;
  @override
  _AddFreezerState createState() => _AddFreezerState();
}

class _AddFreezerState extends State<AddFreezer> {
  final textcontroller = TextEditingController();
  final databaseRef = FirebaseDatabase.instance.reference();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  late String _setTime;
  late String _hour, _minute, _time;
  late String dateTime;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  //randomly generated string
  String rg = "randomly generated";
  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]);
      });
  }

  void addData(String data) {
    databaseRef
        .child("User")
        .child(uid)
        .child(data)
        .set({"FreezerName": data, "RandomGen": rg}).asStream();
  }

  void addFreez(String time) {
    databaseRef
        .child("Freezer")
        .child(rg)
        .set({"Time": time, "Temp": 23, "Bool": false}).asStream();
  }

  late DatabaseReference _freezerref;
  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase();
    _freezerref = databaseRef.reference().child(uid);
    super.initState();
    _dateController.text = DateFormat.yMd().format(DateTime.now());
    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
  }

  AuthClass authClass = AuthClass();

  @override
  Widget build(BuildContext context) {
    dateTime = DateFormat.yMd().format(DateTime.now());
    return Scaffold(
        drawer: ActionBut(),
        appBar: AppBar(
          title: Text("Add"),
          actions: [
            IconButton(
                onPressed: () async {
                  await authClass.logout();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (builder) => SignIn()),
                      (route) => false);
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              InkWell(
                  onTap: () {
                    _selectTime(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      onSaved: (String? val) {
                        _setTime = val!;
                      },
                      enabled: false,
                      keyboardType: TextInputType.text,
                      controller: _timeController,
                      decoration: InputDecoration(
                          disabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          // labelText: 'Time',
                          contentPadding: EdgeInsets.all(5)),
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Form(
                    child: TextField(
                      decoration: InputDecoration(hintText: "freezername"),
                      controller: textcontroller,
                    ),
                  )),
              Center(
                  child: TextButton(
                      child: Text("Save to Database"),
                      onPressed: () {
                        addData(textcontroller.text);
                        addFreez(_timeController.text);
                        textcontroller.clear();
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => FreezerList()),
                            (route) => false);
                      })),
            ],
          ),
        ));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class EditDialog extends StatefulWidget {
  final String randomGenerated;
  final String fn;

  const EditDialog({Key? key, required this.randomGenerated, required this.fn})
      : super(key: key);

  @override
  _EditDialogState createState() =>
      _EditDialogState(this.randomGenerated, this.fn);
}

class _EditDialogState extends State<EditDialog> {
  //randomly generated parsed to edit dialog
  late final String randomGenerated;
  late final String fn;

  _EditDialogState(this.randomGenerated, this.fn);

  late DatabaseReference _freezerref;
  late DatabaseReference _freezerref2;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  late String _setTime;
  late String _hour, _minute, _time;
  late String dateTime;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

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
            [hh, ':', nn, " ", am]).toString();
      });
  }

  final databaseRef = FirebaseDatabase.instance
      .reference()
      .child("Freezer")
      .child("randomly generated");
  final databaseref2 = FirebaseDatabase.instance.reference().child("User");
  void updateData(String time) {
    databaseRef.update({"Time": time}).then((_) {});
    databaseref2.child(uid).child(fn).update({"Time": time}).then((_) {});
  }

  void initState() {
    final FirebaseDatabase database = FirebaseDatabase();
    _freezerref = databaseRef.reference().child(uid);
    _freezerref2 = databaseref2.reference().child("User").child(uid).child(fn);

    super.initState();
    _dateController.text = DateFormat.yMd().format(DateTime.now());
    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Your Time"),
      actions: [
        TextButton(
            onPressed: () {
              updateData(_timeController.text);
            },
            child: Text("save"))
      ],
      content: Container(
        height: 50,
        child: InkWell(
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
      ),
    );
  }
}

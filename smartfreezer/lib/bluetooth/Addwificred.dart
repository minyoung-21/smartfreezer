import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smartfreezer/Action.dart';
import 'package:smartfreezer/Freezer/AddFreezer.dart';
import 'package:smartfreezer/bluetooth/Home.dart';

class AddWifiCred extends StatefulWidget {
  final BluetoothDevice server;

  const AddWifiCred({required this.server});

  @override
  _AddWifiCred createState() => new _AddWifiCred();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _AddWifiCred extends State<AddWifiCred> {
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController wifiname = new TextEditingController();

  final TextEditingController wifipwd = new TextEditingController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  showsnackbar() {
    final snackBar = SnackBar(
        action: SnackBarAction(
            label: "Go back to bluetooth page",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  (MaterialPageRoute(builder: (builder) => MainPage())),
                  (route) => false);
            }),
        content: const Text("Bluetooth not connected"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var _formkey = GlobalKey<FormState>();
  var _formkey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
        drawer: ActionBut(),
        appBar: AppBar(
            title: (isConnecting
                ? Text('Connecting to ' + serverName + '...')
                : isConnected
                    ? Text('Send your wifi credentials to ' + serverName)
                    : Text('Your wifi credentials ' + serverName))),
        body: Column(children: <Widget>[
          Form(
            key: _formkey,
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Wifi Name';
                }
                return null;
              },
              controller: wifiname,
            ),
          ),
          TextButton(
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  if (isConnected != false) {
                    _sendnameandpwd(wifiname.text);
                  } else {
                    showsnackbar();
                  }
                }
              },
              child: Text("Send Name")),
          Form(
            key: _formkey2,
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Wifi Password';
                }
                return null;
              },
              controller: wifipwd,
              decoration: InputDecoration(
                
        ),
              ),
            ),
        
          TextButton(
              onPressed: () {
                if (_formkey2.currentState!.validate()) {
                  if (isConnected != false) {
                    _sendnameandpwd(wifipwd.text);
                  } else {
                    showsnackbar();
                  }
                }
              },
              child: Text("Connect Wifi"))
        ])
        //     ],
        //   ),
        // ),
        );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    print(dataString);
    // if (~index != 0) {
    //   setState(() {
    //     messages.add(
    //       _Message(
    //         1,
    //         backspacesCounter > 0
    //             ? _messageBuffer.substring(
    //                 0, _messageBuffer.length - backspacesCounter)
    //             : _messageBuffer + dataString.substring(0, index),
    //       ),
    //     );
    //     _messageBuffer = dataString.substring(index);
    //   });
    // } else {
    //   _messageBuffer = (backspacesCounter > 0
    //       ? _messageBuffer.substring(
    //           0, _messageBuffer.length - backspacesCounter)
    //       : _messageBuffer + dataString);
    // }
  }

  void _sendnameandpwd(String name) async {

    wifiname.clear();
    wifipwd.clear();
    Navigator.pushAndRemoveUntil(
        context,
        (MaterialPageRoute(builder: (builder) => AddFreezer())),
        (route) => false);
    if (name.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(name + "\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, name));
        });

        //   Future.delayed(Duration(milliseconds: 333)).then((_) {
        //     listScrollController.animateTo(
        //         listScrollController.position.maxScrollExtent,
        //         duration: Duration(milliseconds: 333),
        //         curve: Curves.easeOut);
        //   });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}

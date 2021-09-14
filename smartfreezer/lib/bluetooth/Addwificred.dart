import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smartfreezer/Action.dart';

class AddWifiCred extends StatefulWidget {
  final BluetoothDevice server;

  const AddWifiCred({required this.server});

  @override
  _AddWifiCred createState() => new _AddWifiCred();
}

class _MessageReceived {
  int whom;
  String text;

  _MessageReceived(this.whom, this.text);
}

class _MessageSent {
  int whom;
  String nameofWifi;
  String passofWifi;

  _MessageSent(this.whom, this.nameofWifi, this.passofWifi);
}

class _AddWifiCred extends State<AddWifiCred> {
  static final clientID = 0;
  var connection; //BluetoothConnection

  List<_MessageReceived> messagesReceived = [];
  List<_MessageSent> messagesSent = [];

  String _messageBuffer = '';

  final TextEditingController wifiname = new TextEditingController();
  final TextEditingController wifipass = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
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

      connection.input.listen(_onDataReceived).onDone(() {
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
    if (isConnected()) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  var _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final List<Row> list = messagesReceived.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == 'connected'
                      ? "Connected"
                      : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
        drawer: ActionBut(),
        appBar: AppBar(
            title: (isConnecting
                ? Text('Connecting to ' + widget.server.name! + '...')
                : isConnected()
                    ? Text('Send Credentials to ' + widget.server.name!)
                    : Text('Credentials sent to ' + widget.server.name!))),
        body: SafeArea(
            child: Column(children: <Widget>[
          Form(
            key: _formkey,
            child: Column(children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your WIFI NAME';
                  }
                  return null;
                },
                controller: wifiname,
                decoration: InputDecoration(
                  hintText: isConnecting
                      ? 'Wait until connected...'
                      : isConnected()
                          ? 'Type your WIFI Name...'
                          : 'Freezer got disconnected',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                enabled: isConnected(),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your WIFI PASSWORD";
                  }
                  return null;
                },
                controller: wifipass,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: isConnecting
                      ? 'Wait until connected...'
                      : isConnected()
                          ? 'Type your WIFI Password...'
                          : 'Freezer got disconnected',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                enabled: isConnected(),
              ),
            ]),
          ),
          TextButton(
              onPressed: () {
                if (isConnected()) {
                  if (_formkey.currentState!.validate()) {
                    _sendWifiCred(wifiname.text, wifipass.text);
                    final snackBar = SnackBar(content: Text("Connecting...."));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              child: Text("Send WIFI Credentials")),
          Flexible(
            child: ListView(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                children: list),
          ),
        ])));
  }

  // checkConnection() {
  //   if (messagesReceived.last.text == "connected") {
  //     return showDialog(
  //         context: context,
  //         builder: (_) {
  //           return AlertDialog(content: Text("Connected"), actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.pushAndRemoveUntil(
  //                       context,
  //                       (MaterialPageRoute(builder: (builder) => AddFreezer())),
  //                       (route) => false);
  //                 },
  //                 child: Text("Proceed"))
  //           ]);
  //         });
  //   } else {
  //     return showDialog(
  //         context: context,
  //         builder: (_) {
  //           return AlertDialog(
  //             content: Text("Not Connected"),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text("Type Credentials Again"))
  //             ],
  //           );
  //         });
  //   }
  // }

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
    if (~index != 0) {
      setState(() {
        messagesReceived.add(
          _MessageReceived(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

//send wifi Credentials
  void _sendWifiCred(String name, String pass) async {
    wifiname.clear();
    wifipass.clear();
    if (name.length > 0 && pass.length > 0) {
      try {
        connection.output.add(utf8.encode(name + "\r\n" + pass));
        await connection.input.allSent;
        setState(() {
          messagesSent.add(_MessageSent(clientID, name, pass));
        });
      } catch (e) {
        setState(() {});
      }
    }
  }

  bool isConnected() {
    return connection != null && connection.isConnected;
  }
}

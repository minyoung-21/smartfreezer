import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smartfreezer/Action.dart';
import 'package:smartfreezer/Freezer/AddFreezer.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
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
          TextFormField(
            controller: wifiname,
          ),
          TextButton(
              // onPressed:
              //     isConnected ? () => _sendnameandpwd(wifiname.text) : null,
              onPressed: () {
                _sendnameandpwd(wifiname.text);
              },
              child: Text("Send Name")),
          TextFormField(
            controller: wifipwd,
          ),
          TextButton(
              // onPressed:
              //     isConnected ? () => _sendnameandpwd(wifipwd.text) : null,
              onPressed: () {
                _sendnameandpwd(wifipwd.text);
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
    name = name.trim();
    wifiname.clear();
    wifipwd.clear();

    if (name.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(name + "\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, name));
        });
        Navigator.pushAndRemoveUntil(
            context,
            (MaterialPageRoute(builder: (builder) => AddFreezer())),
            (route) => false);

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

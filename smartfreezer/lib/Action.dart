import 'package:flutter/material.dart';
import 'package:smartfreezer/Freezer/AddFreezer.dart';
import 'package:smartfreezer/bluetooth/Discovery.dart';
import 'bluetooth/MainPage.dart';
import 'Freezer/FreezerList.dart';

class ActionBut extends StatelessWidget {
  const ActionBut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[ Column(
          children: [
            SizedBox(
              height: 50,
            ),
            ListTile(
              title: Text('Freezer List'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => FreezerList()),
                    (route) => false);
              },
            ),
            
            ListTile(
              title: Text('Add Freezer'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => AddFreezer()),
                    (route) => false);
              },
            ),
            ListTile(
              title: Text('Main Page'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => MainPage()),
                    (route) => false);
              },
            ),
            ListTile(
              title: Text('Select the Bluetooth device'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => DiscoveryPage()),
                    (route) => false);
              },
            ),
          ],
        )
      ],
    ));
  }
}

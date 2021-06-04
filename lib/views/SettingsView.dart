import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Notifications"),
              onPressed: () {},
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Your Account"),
              onPressed: () {},
            ),
          ),
          Divider(
            thickness: 1,
            indent: 50,
            endIndent: 50,
            color: Colors.black,
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Privacy & Security"),
              onPressed: () {},
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Terms & Conditions"),
              onPressed: () {},
            ),
          ),
          ListTile(
            title: MaterialButton(
              color: Colors.redAccent,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.logout), Text("Log out")]),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
